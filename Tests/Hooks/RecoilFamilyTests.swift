import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class RecoilFamilyTests: XCTestCase {
  struct TestModule  {
    static var myNumberState = atom { 2 }
    
    static var threeTimesNumberState = atomFamily { (multiplier: Int) -> Int in
      3 * multiplier;
    }
    
    static let myMultipliedState = selectorFamily { (multiplier: Int, get: Getter) -> Int in
      get(myNumberState) * multiplier;
    }
    
    static let getBookByType = atomFamily { (type: String) -> AnyPublisher<[String], Error> in
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
    
    static let fetchBookByType = atomFamily { (type: String) async -> [String] in
      await MockAPI.makeAsync(
        value: ["\(type)-Book1", "\(type)-Book2"],
        delay: TestConfig.mock_async_wait_nanoseconds)
    }
    
    static let fetchBookByCategory = selectorFamily { (category: String, get: Getter) async -> [String] in
      await MockAPI.makeAsync(
        value: ["\(category):Book1", "\(category):Book2"],
        delay: TestConfig.mock_async_wait_nanoseconds)
    }
  }
  
  override func setUp() {
    RecoilStore.shared.reset()
  }
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
}
