import SwiftUI
import XCTest

@testable import RecoilSwift

final class SelectorReadWriteTests: XCTestCase {
    @RecoilTestScope var scope
    
    var accessor: StateAccessor {
        _scope.accessor(deps: [])
    }
    
    override func setUp() {
        _scope.reset()
    }
}

// MARK: - sync selector
extension SelectorReadWriteTests {
    func test_should_return_filtered_names_when_using_filtered_names_selector_given_names_state() {
        let expectation = XCTestExpectation(description: "filtered names")
        let tester = HookTester(scope: _scope) {
            let value = useRecoilValue(RemoteNames.filteredNames)
            if value == ["Ella", "Chris", "Paul"] {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_correct_values_when_using_writable_selector_given_tempCelsiusSelector_and_tempFahrenheitState() {
        let expectation = XCTestExpectation(description: "save Value")
        let tester = HookTester(scope: _scope) {
            let value = useRecoilState(TempCelsiusSelector())
            if value.wrappedValue == 30 {
                expectation.fulfill()
            }
            return value
        }
        
        XCTAssertEqual(tester.value.wrappedValue, 0)
        
        tester.value.wrappedValue = 30
        
        XCTAssertEqual(accessor.getUnsafe(TempFahrenheitState()), 86)
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
}

// MARK: - async
extension SelectorReadWriteTests {
    func test_should_return_books_when_fetching_remote_data_given_remote_data_source() {
        let expectation = XCTestExpectation(description: "get async data source to atom")
        
        let tester = HookTester(scope: _scope) { () -> [String]? in
            let value = useRecoilValue(MockSelector.remoteBooks(["Book1", "Book2"]))
            
            if value == ["Book1", "Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertNil(tester.value)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_nil_when_fetching_remote_data_given_remote_data_source_error() {
        let tester = HookTester(scope: _scope) { () -> [String]? in
            useRecoilValue(RemoteErrorState<[String]>(error: MyError.param))
        }
        
        XCTAssertNil(tester.value)
    }
}
