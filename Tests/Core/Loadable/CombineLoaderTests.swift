import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class CombineLoaderTests: XCTestCase {
  
  func testShouldCallSuccessAndFinally() {
    let successExptation = XCTestExpectation(description: "should call then")
    let finallyExptation = XCTestExpectation(description: "should call finally")
    let loader = CombineLoader {
      MockAPI.makeCombine(result: .success("Success"), delay: TestConfig.mock_async_wait_seconds)
    }
    
    loader
      .toPromise()
      .then { (val: String) in
        if val == "Success" {
         successExptation.fulfill()
        }
      }
      .finally{ finallyExptation.fulfill() }
    
    loader.run()
    
    wait(for: [successExptation, finallyExptation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  func testShouldCallFailedAndFinallyWhenThrowAnError() {
    let failedExptation = XCTestExpectation(description: "should call failed")
    let finallyExptation = XCTestExpectation(description: "should call finally")
    let loader: CombineLoader<String, Error>  = CombineLoader {
      throw MyError.param
    }
    
    loader
      .toPromise()
      .then{ }
      .catch { (e: Error) in
        if (e as? MyError) == MyError.param {
          failedExptation.fulfill()
        }
      }
      .finally{ finallyExptation.fulfill() }
    
    loader.run()
    
    wait(for: [failedExptation, finallyExptation], timeout: TestConfig.mock_async_wait_seconds)
  }
  
  func testShouldCallFailedAndFinallyWhenAPIError() {
    let failedExptation = XCTestExpectation(description: "should call failed")
    let finallyExptation = XCTestExpectation(description: "should call finally")

    let loader: CombineLoader<String, Error> = CombineLoader {
      MockAPI.makeCombine(result: .failure(MyError.param), delay: TestConfig.mock_async_wait_seconds)
    }
    loader
      .toPromise()
      .then{ }
      .catch { (e: Error) in
        if (e as? MyError) == MyError.param {
          failedExptation.fulfill()
        }
      }
      .finally{ finallyExptation.fulfill() }
    
    loader.run()
    
    wait(for: [failedExptation, finallyExptation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  func testShouldCallFinallyWhenCancel() {
    let finallyExptation = XCTestExpectation(description: "should call finally")

    let loader: CombineLoader<String, Error> = CombineLoader {
      MockAPI.makeCombine(result: .failure(MyError.param), delay: TestConfig.mock_async_wait_seconds)
    }
    
    loader
      .toPromise()
      .finally{ finallyExptation.fulfill() }
    
    loader.run()
    loader.cancel()
    
    wait(for: [finallyExptation], timeout: TestConfig.expectation_wait_seconds)
  }
}
