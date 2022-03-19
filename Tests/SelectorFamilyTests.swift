import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class SelectorFamilyTests: XCTestCase {
  struct TestModule  {
    static var myNumberState = atom { 2 }
    
    static let myMultipliedState = selectorFamily { (multiplier: Int, get: Getter) -> Int in
      get(myNumberState) * multiplier;
    }
    
    static let getBookByCategory = selectorFamily { (category: String, get: Getter) -> AnyPublisher<[String], Error> in
      Deferred {
        Future { promise in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            promise(.success(["\(category):Book1", "\(category):Book2"]))
          }
        }
      }.eraseToAnyPublisher()
    }
    
    @available(iOS 15.0, *)
    static let fetchBookByCategory = selectorFamily { (category: String, get: Getter) async -> [String] in
        try? await Task.sleep(nanoseconds: 300_000_000)
        return ["\(category):Book1", "\(category):Book2"]
    }
  }
  
  override func setUp() {
    
  }
}

// MARK: - sync selector
extension SelectorFamilyTests {
  func testParameterValueSelector() {
    var dynamicMultipleNumber = 10
    
    let tester = HookTester {
      useRecoilValue(TestModule.myMultipliedState(dynamicMultipleNumber))
    }
    
    XCTAssertEqual(tester.value, 20)
    
    dynamicMultipleNumber = 100
    tester.update()
    
    XCTAssertEqual(tester.value, 200)
  }
  
  func testCombineParameterSelector() {
    let expectation = XCTestExpectation(description: "Combine selector resolved")
    let tester = HookTester { () -> [String]? in
      let categories = useRecoilValue(TestModule.getBookByCategory("Combine"))
    
      if let value = categories, value == ["Combine:Book1", "Combine:Book2"] {
        expectation.fulfill()
      }
      
      return categories
    }
    
    XCTAssertEqual(tester.value, nil)
    
    wait(for: [expectation], timeout: 0.5)
  }
  
  @available(iOS 15.0, *)
  func testAsyncParameterSelector() {
    let expectation = XCTestExpectation(description: "Async selector resolved.")
    let tester = HookTester { () -> [String]? in
      let categories = useRecoilValue(TestModule.fetchBookByCategory("Async"))
      
      if let value = categories, value == ["Async:Book1", "Async:Book2"] {
        expectation.fulfill()
      }
      
      return categories
    }
    
    XCTAssertEqual(tester.value, nil)
    
    wait(for: [expectation], timeout: 0.5)
  }
}
