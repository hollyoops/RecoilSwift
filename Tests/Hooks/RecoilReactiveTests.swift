import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

private struct TestStates {
    static var rawAtom: Atom<String> {
        atom { "rawValue" }
    }
    
    static var uppercasedNameState: AsyncSelector<String> {
        selector { accessor in
            let string = try accessor.get(rawAtom)
            try await Task.sleep(nanoseconds: TestConfig.mock_async_wait_nanoseconds)
            return string.uppercased()
        }
    }
}

final class RecoilReactiveTests: XCTestCase {
    var accessor: StateAccessor {
        RecoilTest.shared.nodeAccessor.accessor(deps: [])
    }
    
    @MainActor override func setUp() {
        RecoilTest.shared.reset()
        accessor.set(TestStates.rawAtom, "async value")
    }
    
    func test_should_getValueFromUpstreamAsyncSelector_when_useRecoilValueLoadable_given_downstreamAsyncState() {
        let expectation = XCTestExpectation(description: "Async value reovled")
        
        let tester = HookTester { () -> LoadableContent<String> in
            let loadable = useRecoilValueLoadable(TestStates.uppercasedNameState)
            
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
            useRecoilValueLoadable(TestStates.uppercasedNameState)
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
            let string = try await accessor.get(RemoteErrorState<String>(error: MyError.param))
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
