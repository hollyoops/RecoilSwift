import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class LoadableTests: XCTestCase {
  
  enum MyError: String, Error {
    case unknown
    case param
  }
  
  struct TestModule  {
    static var myNumberState = atom { 2 }
    
    static let myMultipliedState = selector { get -> Int in
      get(myNumberState) * 2;
    }
    
    static let myMultipliedStateError = selector { get throws -> Int in
      throw MyError.unknown
    }
    
    static let getBooks = selector { _ in
      makeCombine(result: .success(["Book1", "Book2"]))
    }
    
    static let getBooksError = selector { get -> AnyPublisher<[String], Error> in
      makeCombine(result: .failure(MyError.param))
    }
    
    private static func makeCombine(result: Result<[String], Error>) -> AnyPublisher<[String], Error> {
      Deferred {
        Future { promise in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            promise(result)
          }
        }
      }.eraseToAnyPublisher()
    }
    
    @available(iOS 15.0, *)
    static let fetchBook = selector { get async -> [String] in
      try? await Task.sleep(nanoseconds: 300_000_000)
      return ["Book1", "Book2"]
    }
    
    @available(iOS 15.0, *)
    static let fetchBookError = selector { get async throws -> [String] in
      try? await Task.sleep(nanoseconds: 300_000_000)
      throw MyError.param
    }
  }
  
  override func setUp() {
    
  }
}

// MARK: - sync loadable
extension LoadableTests {
  func testSyncLoadableFullFilled() {
    let tester = HookTester {
      useRecoilValueLoadble(TestModule.myMultipliedState)
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, false)
    
    XCTAssertEqual(tester.value.data, 4)
  }
  
  func testSyncLoadableRejected() {
    let tester = HookTester {
      useRecoilValueLoadble(TestModule.myMultipliedStateError)
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, false)
    
    XCTAssertEqual(tester.value.data, nil)
    
    XCTAssertEqual(tester.value.error as? MyError, MyError.unknown)
  }
}

// MARK: - async
extension LoadableTests {
  func testCombineLoadableFullFilled() {
    let expectation = XCTestExpectation(description: "Combine value reovled")
    
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadble(TestModule.getBooks)
      
      if let value = loadable.data, value == ["Book1", "Book2"] {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: 0.5)
  }
  
  func testCombineLoadableFailed() {
    let expectation = XCTestExpectation(description: "Combine error")
    
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadble(TestModule.getBooksError)
      
      if let error = loadable.error as? MyError, error == .param {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: 0.5)
  }
  
  @available(iOS 15.0, *)
  func testAsyncLoadableFullFilled() {
    let expectation = XCTestExpectation(description: "Async selector resolved.")
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadble(TestModule.fetchBook)
      
      if let value = loadable.data, value == ["Book1", "Book2"] {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: 0.5)
  }
  
  
  @available(iOS 15.0, *)
  func testAsyncLoadableFailed() {
    let expectation = XCTestExpectation(description: "Combine error")
    
    let tester = HookTester { () -> LoadBox<[String], Error> in
      let loadable = useRecoilValueLoadble(TestModule.fetchBookError)
      
      if let error = loadable.error as? MyError, error == .param {
        expectation.fulfill()
      }
      
      return loadable
    }
    
    XCTAssertEqual(tester.value.isAsynchronous, true)
    
    wait(for: [expectation], timeout: 0.5)
  }
}
