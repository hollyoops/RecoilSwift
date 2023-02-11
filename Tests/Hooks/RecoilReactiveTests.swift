import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class RecoilReactiveTests: XCTestCase {
    typealias Selector = RecoilSwift.Selector
    
    struct TestModule  {
        static let stringAtom = atom { "rawValue" }
        static let upstreamSyncState = selector { _ throws -> String in "sync value" }
        static let downstreamSyncState = selector { get throws -> String in
            let string = get(TestModule.upstreamSyncState)
            return string.uppercased()
        }
        
        static let upstreamErrorState = makeCombineAtom(error: MyError.param, type: String.self)
        
        static let upstreamAsyncState = makeAsyncSelector(value: "async value")
        static let downstreamAsyncState = selector { get throws -> String in
            let string = get(TestModule.upstreamAsyncState) ?? ""
            return string.uppercased()
        }
    }
    
    @MainActor override func setUp() {
        RecoilTest.shared.reset()
    }
}

extension RecoilReactiveTests {
    func test_should_get_value_from_upstream_sync_selector() {
        let tester = HookTester {
            useRecoilValue(TestModule.downstreamSyncState)
        }
        
        XCTAssertEqual(tester.value, "sync value".uppercased())
    }
    
    func test_should_get_value_from_upstream_async_selector() {
        let expectation = XCTestExpectation(description: "Async value resolved")
        
        let tester = HookTester { () -> LoadableContent<String> in
            let loadable = useRecoilValueLoadable(TestModule.downstreamAsyncState)
            
            if loadable.data == "async value".uppercased() {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertTrue(tester.value.data == "")
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_loading_when_upstream_is_loading() {
        let expectation = XCTestExpectation(description: "should return correct loading status")
        
        let tester = HookTester { () -> LoadableContent<String> in
            useRecoilValueLoadable(TestModule.downstreamAsyncState)
        }
        
        XCTAssertTrue(tester.value.isLoading)
        DispatchQueue.main.asyncAfter(deadline: .now() + TestConfig.expectation_wait_seconds) {
            if tester.value.isLoading == false {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_error_when_one_of_upstream_is_error() {
        let expectation = XCTestExpectation(description: "should return correct error status")
        
        let selectorWithError = Selector { get throws -> String in
            let string = get(TestModule.upstreamErrorState) ?? ""
            return string.uppercased()
        }
        
        let tester = HookTester { () -> LoadableContent<String> in
            useRecoilValueLoadable(selectorWithError)
        }
        
        XCTAssertFalse(tester.value.hasError)
        DispatchQueue.main.asyncAfter(deadline: .now() + TestConfig.expectation_wait_seconds) {
            if tester.value.hasError {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
}
