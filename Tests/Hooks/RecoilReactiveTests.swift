import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class RecoilReactiveTests: XCTestCase {
    typealias Selector = RecoilSwift.Selector
    
    struct TestModule {
        static let stringAtom = atom { "rawValue" }
        static let upstreamSyncState = selector { _ in "sync value" }
        static let downstreamSyncState = selector { accessor in
            let string = try accessor.get(TestModule.upstreamSyncState)
            return string.uppercased()
        }
        
        static let upstreamErrorState = makeCombineSelector(error: MyError.param, type: String.self)
        static let upstreamAsyncState = makeAsyncSelector(value: "async value")
        static let downstreamAsyncState = selector { accessor in
            let string = try await accessor.get(TestModule.upstreamAsyncState)
            return string.uppercased()
        }
    }
    
    @MainActor override func setUp() {
        RecoilTest.shared.reset()
    }
}

extension RecoilReactiveTests {
    func test_should_getValueFromUpstreamSyncSelector_when_useRecoilValue_given_downstreamSyncState() {
        let tester = HookTester {
            useRecoilValue(TestModule.downstreamSyncState)
        }
        
        XCTAssertEqual(tester.value, "sync value".uppercased())
    }
    
    func test_should_getValueFromUpstreamAsyncSelector_when_useRecoilValueLoadable_given_downstreamAsyncState() {
        let expectation = XCTestExpectation(description: "Async value reovled")
        
        let tester = HookTester { () -> LoadableContent<String> in
            let loadable = useRecoilValueLoadable(TestModule.downstreamAsyncState)
            
            if loadable.data == "async value".uppercased() {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertNil(tester.value.data)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_returnLoading_when_useRecoilValueLoadable_given_downstreamAsyncState() {
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
    
    func test_should_returnError_when_useRecoilValueLoadable_given_selectorWithError() {
        let expectation = XCTestExpectation(description: "should return correct loading status")
        
        let selectorWithError = AsyncSelector { accessor in
            let string = try await accessor.get(TestModule.upstreamErrorState)
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
