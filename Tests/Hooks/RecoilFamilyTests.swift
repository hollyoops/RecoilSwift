import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class RecoilFamilyTests: XCTestCase {
  struct TestModule  {
    static var myNumberState = atom { 2 }
    
    static var threeTimesNumberState = atomFamily { (multiplier: Int, get: Getter) -> Int in
      3 * multiplier;
    }
    
    static let myMultipliedState = selectorFamily { (multiplier: Int, get: Getter) -> Int in
      get(myNumberState) * multiplier;
    }
    
    static let getBookByType = atomFamily { (type: String, get: Getter) -> AnyPublisher<[String], Error> in
      MockAPI.makeCombine(
        result: .success(["\(type)-Book1", "\(type)-Book2"]),
        delay: TestConfig.mock_async_wait_seconds
      )
    }
    
    static let getBookByCategory = selectorFamily { (category: String, get: Getter) -> AnyPublisher<[String], Error> in
      MockAPI.makeCombine(
        result: .success(["\(category):Book1", "\(category):Book2"]),
        delay: TestConfig.mock_async_wait_seconds
      )
    }
    
    @available(iOS 15.0, *)
    static let fetchBookByType = atomFamily { (type: String, get: Getter) async -> [String] in
      await MockAPI.makeAsync(
        value: ["\(type)-Book1", "\(type)-Book2"],
        delay: TestConfig.mock_async_wait_nanoseconds)
    }
    
    @available(iOS 15.0, *)
    static let fetchBookByCategory = selectorFamily { (category: String, get: Getter) async -> [String] in
      await MockAPI.makeAsync(
        value: ["\(category):Book1", "\(category):Book2"],
        delay: TestConfig.mock_async_wait_nanoseconds)
    }
  }
  
  override func setUp() { }
}

// MARK: - atoms
extension RecoilFamilyTests {
  func testAtomShouldReturnParameterValue() {
    var dynamicMultipleNumber = 10
    
    let tester = HookTester {
      useRecoilValue(TestModule.threeTimesNumberState(dynamicMultipleNumber))
    }
    
    XCTAssertEqual(tester.value, 30)
    
    dynamicMultipleNumber = 100
    tester.update()
    
    XCTAssertEqual(tester.value, 300)
  }
  
  func testShouldFetchComputerRemoteData() {
    let expectation = XCTestExpectation(description: "Combine selector resolved")
    let tester = HookTester { () -> [String]? in
      let value = useRecoilValue(TestModule.getBookByType("Computer"))
      
      if value == ["Computer-Book1", "Computer-Book2"] {
        expectation.fulfill()
      }
      
      return value
    }
    
    XCTAssertEqual(tester.value, nil)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  @available(iOS 15.0, *)
  func testShouldAsyncParameterSelector() {
    let expectation = XCTestExpectation(description: "Async selector resolved.")
    let tester = HookTester { () -> [String]? in
      let value = useRecoilValue(TestModule.fetchBookByType("edu"))
      
      if value == ["edu-Book1", "edu-Book2"] {
        expectation.fulfill()
      }
      
      return value
    }
    
    XCTAssertEqual(tester.value, nil)
    
    wait(for: [expectation], timeout: 0.5)
  }
}

// MARK: - selectors
extension RecoilFamilyTests {
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
      let value = useRecoilValue(TestModule.getBookByCategory("Combine"))
      
      if value == ["Combine:Book1", "Combine:Book2"] {
        expectation.fulfill()
      }
      
      return value
    }
    
    XCTAssertEqual(tester.value, nil)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  @available(iOS 15.0, *)
  func testAsyncParameterSelector() {
    let expectation = XCTestExpectation(description: "Async selector resolved.")
    let tester = HookTester { () -> [String]? in
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
