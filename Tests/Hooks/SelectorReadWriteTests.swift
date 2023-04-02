import SwiftUI
import XCTest

@testable import RecoilSwift

final class SelectorReadWriteTests: XCTestCase {
    struct TestModule  {
        static var namesState = atom { ["", "Ella", "Chris", "", "Paul"] }
        static let filteredNamesState = selector { accessor -> [String] in
            accessor.getUnsafe(namesState).filter { $0 != "" }
        }
        
        static let tempFahrenheitState: Atom<Int> = atom(32)
        static let tempCelsiusSelector: MutableSelector<Int> = selector(
            get: { context in
                let fahrenheit = context.getUnsafe(tempFahrenheitState)
                return (fahrenheit - 32) * 5 / 9
            },
            set: { context, newValue in
                let newFahrenheit = (newValue * 9) / 5 + 32
                context.accessor.set(tempFahrenheitState, newFahrenheit)
            }
        )
    }
    
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
        let tester = HookTester(scope: _scope) {
            useRecoilValue(TestModule.filteredNamesState)
        }
        
        XCTAssertEqual(tester.value, ["Ella", "Chris", "Paul"])
    }
    
    func test_should_return_correct_values_when_using_writable_selector_given_tempCelsiusSelector_and_tempFahrenheitState() {
        let expectation = XCTestExpectation(description: "save Value")
        let tester = HookTester(scope: _scope) {
            let value = useRecoilState(TestModule.tempCelsiusSelector)
            if value.wrappedValue == 30 {
                expectation.fulfill()
            }
            return value
        }
        
        XCTAssertEqual(tester.value.wrappedValue, 0)
        
        tester.value.wrappedValue = 30
        
        XCTAssertEqual(accessor.getUnsafe(TestModule.tempFahrenheitState), 86)
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
