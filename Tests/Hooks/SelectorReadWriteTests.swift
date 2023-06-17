#if canImport(Hooks)

import SwiftUI
import XCTest
import RecoilSwiftTestKit

@testable import RecoilSwift

final class SelectorReadWriteTests: XCTestCase {
    @RecoilTestScope var recoil
    
    var accessor: StateAccessor {
        _recoil.accessor(deps: [])
    }
    
    override func setUp() {
        _recoil.purge()
    }
}

// MARK: - sync selector
extension SelectorReadWriteTests {
    func test_should_return_filtered_names_when_using_filtered_names_selector_given_names_state() {
        let expectation = XCTestExpectation(description: "filtered names")
        let tester = HookTester(scope: _recoil) {
            let value = useRecoilValue(RemoteNames.filteredNames)
            if value == ["Ella", "Chris", "Paul"] {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_correct_values_when_using_writable_selector_given_tempCelsiusSelector_and_tempFahrenheitState() {
        let tester = HookTester(scope: _recoil) {
            useRecoilState(TempCelsiusSelector())
        }
        
        XCTAssertEqual(tester.value.wrappedValue, 0)
        
        tester.value.wrappedValue = 30
        
        XCTAssertEqual(accessor.getUnsafe(TempFahrenheitState()), 86)
    }
}

// MARK: - async
extension SelectorReadWriteTests {
    func test_should_return_books_when_fetching_remote_data_given_remote_data_source() {
        let expectation = XCTestExpectation(description: "get async data source to atom")
        
        let tester = HookTester(scope: _recoil) { () -> [String]? in
            let value = useRecoilValue(MockAsyncSelector(value: ["Book1", "Book2"]))
            
            if value == ["Book1", "Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertNil(tester.value)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_return_nil_when_fetching_remote_data_given_remote_data_source_error() {
        let tester = HookTester(scope: _recoil) { () -> [String]? in
            useRecoilValue(MockAtom<[String]>(error: TestError.param))
        }
        
        XCTAssertNil(tester.value)
    }
}

#endif
