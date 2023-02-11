import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

enum MyError: String, Error {
    case unknown
    case param
}

final class LoadableTests: XCTestCase {
    
    struct TestModule  {
        static var myNumberState = atom { 2 }
        
        static let myMultipliedState = selector { get -> Int in
            get(myNumberState) * 2;
        }
        
        static let myCustomMultipliedState = selectorFamily { (multiplier: Int, get: Getter) -> Int in
            get(myNumberState) * multiplier;
        }
        
        static let myMultipliedStateError = makeSelector(error: MyError.unknown, type: Int.self)
        
        static let getBooks = makeCombineSelector(value: ["Book1", "Book2"])
        static let getBooksError = makeCombineSelector(error: MyError.param, type: [String].self)
        
        static let fetchBookAtomState = makeAsyncAtom(value: ["Book1", "Book2"])
        static let fetchBookAtomStateWithError = makeAsyncAtom(error: MyError.param, type: [String].self)
        
        static let getBooksAtom = makeCombineAtom(value: ["Book1", "Book2"])
        static let getBooksErrorAtom = makeCombineAtom(error: MyError.param, type: [String].self)
        
        static let fetchBook = makeAsyncSelector(value: ["Book1", "Book2"])
        static let fetchBookError = makeAsyncSelector(error: MyError.param, type: [String].self)
    }
    
    @MainActor override func setUp() {
        RecoilTest.shared.reset()
    }
}

// MARK: - sync loadable
extension LoadableTests {
    func test_sync_loadable_should_be_fulfilled_when_using_my_multiplied_state() {
        let tester = HookTester {
            useRecoilValueLoadable(TestModule.myMultipliedState)
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, false)
        
        XCTAssertEqual(tester.value.data, 4)
    }
    
    func test_custom_loadable_should_be_fulfilled_when_using_my_custom_multiplied_state() {
        let tester = HookTester {
            useRecoilValueLoadable(TestModule.myCustomMultipliedState(3))
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, false)
        
        XCTAssertEqual(tester.value.data, 6)
    }
    
    func test_sync_loadable_should_be_rejected_when_using_my_multiplied_state_error() {
        let tester = HookTester {
            useRecoilValueLoadable(TestModule.myMultipliedStateError)
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, false)
        
        XCTAssertEqual(tester.value.data, nil)
        
        XCTAssertTrue(tester.value.containError(of: MyError.unknown))
    }
}

// MARK: - async selector
extension LoadableTests {
    func test_combine_loadable_should_be_fulfilled_when_using_get_books() {
        let expectation = XCTestExpectation(description: "Combine value resolved")
        
        let tester = HookTester { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(TestModule.getBooks)
            
            if loadable.data == ["Book1", "Book2"] {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, true)
        XCTAssertEqual(tester.value.isLoading, true)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_combine_loadable_should_fail_when_using_get_books_error() {
        let expectation = XCTestExpectation(description: "Combine error")
        
        let tester = HookTester { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(TestModule.getBooksError)
            
            if loadable.containError(of: MyError.param) {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, true)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_async_loadable_should_be_fulfilled_when_using_fetch_book() {
        let expectation = XCTestExpectation(description: "Async selector resolved.")
        let tester = HookTester { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(TestModule.fetchBook)
            
            if loadable.data == ["Book1", "Book2"] {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, true)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
    
    func test_async_loadable_should_fail_when_using_fetch_book_error() {
        let expectation = XCTestExpectation(description: "Combine error")
        
        let tester = HookTester { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(TestModule.fetchBookError)
            
            if loadable.containError(of: MyError.param) {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, true)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
}
