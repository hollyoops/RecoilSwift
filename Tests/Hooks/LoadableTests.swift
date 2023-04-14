import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

enum MyError: String, Error {
    case unknown
    case param
}

typealias Selector = RecoilSwift.Selector

final class LoadableTests: XCTestCase {
    @RecoilTestScope var recoil
    
    struct TestModule  {
        static var myNumberState: Atom<Int> {
            atom { 2 }
        }
        
        static var myMultipliedState: Selector<Int> {
            selector { accessor in
                accessor.getUnsafe(myNumberState) * 2;
            }
        }
        
        static var myCustomMultipliedState: SelectorFamily<Int, Int> {
            selectorFamily { (multiplier, accessor) in
                accessor.getUnsafe(myNumberState) * multiplier;
            }
        }
    }
    
    override func setUp() {
        _recoil.reset()
    }
}

// MARK: - sync loadable
extension LoadableTests {
    func test_sync_loadable_should_be_fulfilled_when_using_my_multiplied_state() {
        let tester = HookTester(scope: _recoil) {
            useRecoilValueLoadable(TestModule.myMultipliedState)
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, false)
        
        XCTAssertEqual(tester.value.data, 4)
    }
    
    func test_custom_loadable_should_be_fulfilled_when_using_my_custom_multiplied_state() {
        let tester = HookTester(scope: _recoil) {
            useRecoilValueLoadable(TestModule.myCustomMultipliedState(3))
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, false)
        
        XCTAssertEqual(tester.value.data, 6)
    }
    
    func test_sync_loadable_should_be_rejected_when_using_my_multiplied_state_error() {
        let tester = HookTester(scope: _recoil) {
            useRecoilValueLoadable(ErrorState<Int>(error: MyError.unknown))
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
        
        let tester = HookTester(scope: _recoil) { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(
                MockSelector.remoteBooksCombine(["Book1", "Book2"])
            )
            
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
        
        let tester = HookTester(scope: _recoil) { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(
                RemoteErrorState<[String]>(error: MyError.param)
            )
            
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
        let tester = HookTester(scope: _recoil) { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(MockSelector.remoteBooks(["Book1", "Book2"]))
            
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
        
        let tester = HookTester(scope: _recoil) { () -> LoadableContent<[String]> in
            let loadable = useRecoilValueLoadable(
                RemoteErrorState<[String]>(error: MyError.param)
            )
            
            if loadable.containError(of: MyError.param) {
                expectation.fulfill()
            }
            
            return loadable
        }
        
        XCTAssertEqual(tester.value.isAsynchronous, true)
        
        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
    }
}
