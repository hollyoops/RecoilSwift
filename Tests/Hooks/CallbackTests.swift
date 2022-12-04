import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

extension XCTestCase {
  func wait(timeInSeconds: TimeInterval) {
    let expectation = XCTestExpectation(description: "Wait")

    DispatchQueue.main.asyncAfter(deadline: .now() + timeInSeconds) {
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: timeInSeconds + 0.1)
  }
}

final class CallbackTests: XCTestCase {
  struct TestModule  {
    static var numberState: Atom<Int>!
    
    static func add(context: RecoilCallbackContext, number: Int) -> Int {
      let num = context.get(numberState)
      let final = number + num
      context.set(numberState, final)
      return final
    }
    
    static func addThenMultiple(context: RecoilCallbackContext, number: Int, multiple: Int) -> Int {
      let num = context.get(numberState)
      let final = (number + num) * multiple
      context.set(numberState, final)
      return final
    }
    
    static func addByRemote(context: RecoilCallbackContext) {
      func fetchRemoteNumber() -> AnyPublisher<Int, Error> {
        Deferred {
            Future { promise in
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    promise(.success(1000))
                }
            }
        }.eraseToAnyPublisher()
      }
      let num = context.get(numberState)
      fetchRemoteNumber()
        .sink(receiveCompletion: { _ in },
              receiveValue: { context.set(numberState, $0 + num) })
        .store(in: context)
    }
    
    static func square(context: RecoilCallbackContext) {
      let num = context.get(numberState)
      context.set(numberState, num * num)
    }
  }
    
  var getter: Getter!
  override func setUp() {
    getter = Getter(store: RecoilStore.shared)
    TestModule.numberState = atom { 2 }
  }
}

// MARK: - Sync
extension CallbackTests {
  func testSyncAddCallback() {
    let tester = HookTester {
      useRecoilCallback(TestModule.add(context:number:))
    }
    
    let value = tester.value(10)
    
    XCTAssertEqual(value, 12)
    XCTAssertEqual(getter(TestModule.numberState), 12)
  }
  
  func testSyncAddThenMultipleCallback() {
    let tester = HookTester {
      useRecoilCallback(TestModule.addThenMultiple(context:number:multiple:))
    }
    
    let value = tester.value(10, 5)
    
    XCTAssertEqual(value, 60)
    XCTAssertEqual(getter(TestModule.numberState), 60)
  }
  
  func testSyncDoubleCallback() {
    let tester = HookTester {
      useRecoilCallback(TestModule.square(context:))
    }
    
    tester.value()
    tester.value()
    
    XCTAssertEqual(getter(TestModule.numberState), 16)
  }
}

// MARK: - Async
extension CallbackTests {
  func testAsyncAddValuef() {
    let tester = HookTester {
      useRecoilCallback(TestModule.addByRemote)
    }
    
    tester.value()
    XCTAssertEqual(getter(TestModule.numberState), 2)
    
    wait(timeInSeconds: 0.5)
    
    XCTAssertEqual(getter(TestModule.numberState), 1002)
  }
}
