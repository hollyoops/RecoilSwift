import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class RecoilFamilyTests: XCTestCase {
    @RecoilTestScope var recoil
    
    struct TestModule  {
        static var myNumberState: Atom<Int> {
            atom { 2 }
        }
            
        static var threeTimesNumberState: AtomFamily<Int, Int> {
            atomFamily { (multiplier: Int) -> Int in
                3 * multiplier;
            }
        }
            
        static var myMultipliedState: SelectorFamily<Int, Int> {
            selectorFamily { (multiplier: Int, accessor: StateGetter) -> Int in
                accessor.getUnsafe(myNumberState) * multiplier;
            }
        }
            
        static var getBookByType: AsyncAtomFamily<String, [String]> {
            atomFamily { (type: String) -> AnyPublisher<[String], Error> in
                MockAPI.makeCombine(
                    result: .success(["\(type)-Book1", "\(type)-Book2"]),
                    delay: TestConfig.mock_async_wait_seconds
                )
            }
        }
            
        static var getBookByCategory: AsyncSelectorFamily<String, [String]> {
            selectorFamily { (category: String, accessor: StateGetter) -> AnyPublisher<[String], Error> in
                MockAPI.makeCombine(
                    result: .success(["\(category):Book1", "\(category):Book2"]),
                    delay: TestConfig.mock_async_wait_seconds
                )
            }
        }
            
        static var fetchBookByType: AsyncAtomFamily<String, [String]> {
            atomFamily { (type: String) async -> [String] in
                await MockAPI.makeAsync(
                    value: ["\(type)-Book1", "\(type)-Book2"],
                    delay: TestConfig.mock_async_wait_nanoseconds)
            }
        }
            
        static var fetchBookByCategory: AsyncSelectorFamily<String, [String]> {
            selectorFamily { (category: String, accessor: StateGetter) async -> [String] in
                await MockAPI.makeAsync(
                    value: ["\(category):Book1", "\(category):Book2"],
                    delay: TestConfig.mock_async_wait_nanoseconds)
            }
        }
    }
    
    override func setUp() {
        _recoil.reset()
    }
}

// MARK: - atoms
extension RecoilFamilyTests {
    func test_atom_should_return_parameter_value_given_dynamic_multiple_number() {
        var dynamicMultipleNumber = 10
        
        let tester = HookTester(scope: _recoil) {
            useRecoilValue(TestModule.threeTimesNumberState(dynamicMultipleNumber))
        }
        
        XCTAssertEqual(tester.value, 30)
        
        dynamicMultipleNumber = 100
        tester.update()
        
        XCTAssertEqual(tester.value, 300)
    }
    
    func test_should_fetch_computer_remote_data_given_book_type() {
        let expectation = XCTestExpectation(description: "Combine selector resolved")
        let tester = HookTester(scope: _recoil) { () -> [String]? in
            let value = useRecoilValue(TestModule.getBookByType("Computer"))
            
            if value == ["Computer-Book1", "Computer-Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertEqual(tester.value, nil)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_fetch_async_parameter_selector_given_book_type() {
        let expectation = XCTestExpectation(description: "Async selector resolved.")
        let tester = HookTester(scope: _recoil) { () -> [String]? in
            let value = useRecoilValue(TestModule.fetchBookByType("edu"))
            
            if value == ["edu-Book1", "edu-Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertEqual(tester.value, nil)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
}

// MARK: - selectors
extension RecoilFamilyTests {
    func test_should_return_parameter_value_given_dynamic_multiple_number_using_selector() {
        var dynamicMultipleNumber = 10
        
        let tester = HookTester(scope: _recoil) {
            useRecoilValue(TestModule.myMultipliedState(dynamicMultipleNumber))
        }
        
        XCTAssertEqual(tester.value, 20)
        
        dynamicMultipleNumber = 100
        tester.update()
        
        XCTAssertEqual(tester.value, 200)
    }
    
    func test_should_combine_parameter_selector_given_book_category() {
        let expectation = XCTestExpectation(description: "Combine selector resolved")
        let tester = HookTester(scope: _recoil) { () -> [String]? in
            let value = useRecoilValue(TestModule.getBookByCategory("Combine"))
            
            if value == ["Combine:Book1", "Combine:Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertEqual(tester.value, nil)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_should_fetch_async_parameter_selector_given_book_category() {
        let expectation = XCTestExpectation(description: "Async selector resolved.")
        let tester = HookTester(scope: _recoil) { () -> [String]? in
            let value = useRecoilValue(TestModule.fetchBookByCategory("Async"))
            
            if value == ["Async:Book1", "Async:Book2"] {
                expectation.fulfill()
            }
            
            return value
        }
        
        XCTAssertEqual(tester.value, nil)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
}
