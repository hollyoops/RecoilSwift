import SwiftUI
import XCTest

@testable import RecoilSwift

final class SelectorReadWriteTests: XCTestCase {
    struct TestModule  {
        static var namesState = atom { ["", "Ella", "Chris", "", "Paul"] }
        static let filteredNamesState = selector { get -> [String] in
            get(namesState).filter { $0 != "" }
        }
        
        static let tempFahrenheitState: Atom<Int> = atom(32)
        static let tempCelsiusSelector: MutableSelector<Int> = selector(
            get: { get in
                let fahrenheit = get(tempFahrenheitState)
                return (fahrenheit - 32) * 5 / 9
            },
            set: { context, newValue in
                let newFahrenheit = (newValue * 9) / 5 + 32
                context.set(tempFahrenheitState, newFahrenheit)
            }
        )
        
        static var remoteDataSource = makeAsyncSelector(value: ["Book1", "Book2"])
        static var remoteDataSourceError = makeAsyncSelector(
            error: MyError.param,
            type: [String].self
        )
    }
    
    var getter: Getter!
    @MainActor override func setUp() {
        RecoilTest.shared.reset()
        getter = RecoilTest.shared.nodeAccessor.getter()
    }
}

// MARK: - sync selector
extension SelectorReadWriteTests {
    func test_should_return_filtered_names_when_using_filtered_names_selector_given_names_state() {
        let tester = HookTester {
            useRecoilValue(TestModule.filteredNamesState)
        }
        
        XCTAssertEqual(tester.value, ["Ella", "Chris", "Paul"])
    }
    
    func test_should_return_correct_values_when_using_writable_selector_given_tempCelsiusSelector_and_tempFahrenheitState() {
        let tester = HookTester {
            useRecoilState(TestModule.tempCelsiusSelector)
        }
        
        XCTAssertEqual(tester.value.wrappedValue, 0)
        
        tester.value.wrappedValue = 30
        
        XCTAssertEqual(getter(TestModule.tempFahrenheitState), 86)
        XCTAssertEqual(tester.value.wrappedValue, 30)
    }
}

// MARK: - async
extension SelectorReadWriteTests {
    func test_should_return_books_when_fetching_remote_data_given_remote_data_source() {
        let expectation = XCTestExpectation(description: "get async data source to atom")
        
        let tester = HookTester { () -> [String]? in
            let value = useRecoilValue(TestModule.remoteDataSource)
            
            if value == ["Book1", "Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertNil(tester.value)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_nil_when_fetching_remote_data_given_remote_data_source_error() {
        let tester = HookTester { () -> [String]? in
            useRecoilValue(TestModule.remoteDataSourceError)
        }
        
        XCTAssertNil(tester.value)
    }
}
