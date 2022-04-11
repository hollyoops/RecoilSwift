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
  
    @available(iOS 15.0, *)
    static let fetchBook = makeAsyncSelector(value: ["Book1", "Book2"])
    
    @available(iOS 15.0, *)
    static let fetchBookError = makeAsyncSelector(error: MyError.param, type: [String].self)
  }
  
  override func setUp() { }
}

// MARK: - sync loadable
extension LoadableTests {
  func testSyncLoadableFullFilled() {
    let tester = HookTester {
      useRecoilValueLoadable(TestModule.myMultipliedState)
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, false)
    
    XCTAssertEqual(tester.value.data, 4)
  }
  
  func testCustomLoadableFullFilled() {
    let tester = HookTester {
      useRecoilValueLoadable(TestModule.myCustomMultipliedState(3))
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, false)
    
    XCTAssertEqual(tester.value.data, 6)
  }
  
  func testSyncLoadableRejected() {
    let tester = HookTester {
      useRecoilValueLoadable(TestModule.myMultipliedStateError)
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, false)
    
    XCTAssertEqual(tester.value.data, nil)
    
    XCTAssertEqual(tester.value.error as? MyError, MyError.unknown)
  }
}

// MARK: - async selector
extension LoadableTests {
  func testCombineLoadableFullFilled() {
    let expectation = XCTestExpectation(description: "Combine value reovled")
    
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadable(TestModule.getBooks)
      
      if let value = loadable.data, value == ["Book1", "Book2"] {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    XCTAssertEqual(tester.value.isLoading, true)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  func testCombineLoadableFailed() {
    let expectation = XCTestExpectation(description: "Combine error")
    
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadable(TestModule.getBooksError)
      
      if let error = loadable.error as? MyError, error == .param {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  @available(iOS 15.0, *)
  func testAsyncLoadableFullFilled() {
    let expectation = XCTestExpectation(description: "Async selector resolved.")
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadable(TestModule.fetchBook)
      
      if let value = loadable.data, value == ["Book1", "Book2"] {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  
  @available(iOS 15.0, *)
  func testAsyncLoadableFailed() {
    let expectation = XCTestExpectation(description: "Combine error")
    
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadable(TestModule.fetchBookError)
      
      if let error = loadable.error as? MyError, error == .param {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
}
