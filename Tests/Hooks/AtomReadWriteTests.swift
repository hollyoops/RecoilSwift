import SwiftUI
import XCTest

@testable import RecoilSwift

final class AtomReadWriteTests: XCTestCase {
  struct TestModule  {
    static var stringAtom: Atom<String>!
    static var remoteDataSource: AsyncAtom<[String], Error>!
    static var remoteDataSourceError: AsyncAtom<[String], Error>!
  }
  
  override func setUp() {
    Store.shared.reset()
    TestModule.stringAtom = atom { "rawValue" }
    TestModule.remoteDataSource = makeAsyncAtom(value: ["Book1", "Book2"])
    TestModule.remoteDataSourceError = makeAsyncAtom(error: MyError.param, type: [String].self)
  }
  
  func testReadOnlyAtom() {
    let tester = HookTester {
      useRecoilValue(TestModule.stringAtom)
    }
    
    XCTAssertEqual(tester.value, "rawValue")
  }
  
  func testReadWriteAtom() {
    let tester = HookTester {
      useRecoilState(TestModule.stringAtom)
    }
    
    XCTAssertEqual(tester.value.wrappedValue, "rawValue")
    
    tester.value.wrappedValue = "newValue"
    
    XCTAssertEqual(tester.value.wrappedValue, "newValue")
  }
}

// MARK: - async
extension AtomReadWriteTests {
  func testUseAtomValueShouldFetchRemoteDataSuccess() {
    let expectation = XCTestExpectation(description: "get async data source to atom")
    
    let tester = HookTester { () -> [String]? in
      let value = useRecoilValue(TestModule.remoteDataSource)
      
      if value == ["Book1", "Book2"] {
        expectation.fulfill()
      }
      
      return value
    }
    
    XCTAssertNil(tester.value)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  func testUseAtomStateShouldFetchRemoteData() {
    let expectation = XCTestExpectation(description: "Should Fetch Remote Data success for useState")
    
    let tester = HookTester { () -> Binding<[String]?> in
      let value = useRecoilState(TestModule.remoteDataSource)
      
      if value.wrappedValue == ["Book1", "Book2"] {
        expectation.fulfill()
      }
      
      return value
    }
    
    XCTAssertNil(tester.value.wrappedValue)
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  func testUseAtomStateShouldFetchRemoteDataFail() {
    let expectation = XCTestExpectation(description: "return nil to atom if failed")
    
    let tester = HookTester { () -> Binding<[String]?> in
      useRecoilState(TestModule.remoteDataSourceError)
    }
    
    XCTAssertNil(tester.value.wrappedValue)
    
    tester.value.wrappedValue = ["fake book"]
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      if tester.value.wrappedValue == nil {
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
  }
  
  func testUseAtomStateShouldSetDataSuccess() {
    let tester = HookTester { () -> Binding<[String]?> in
      useRecoilState(TestModule.remoteDataSource)
    }
    
    XCTAssertNil(tester.value.wrappedValue)
    
    tester.value.wrappedValue = ["fake book"]
    
    XCTAssertEqual(tester.value.wrappedValue, ["fake book"])
  }
}
