import SwiftUI
import XCTest

@testable import RecoilSwift

final class AtomReadWriteTests: XCTestCase {
  struct TestModule  {
    static var stringAtom: Atom<String>!
    static var remoteDataSource: AsyncAtom<[String]>!
    static var remoteDataSourceError: AsyncAtom<[String]>!
  }
  
  override func setUp() {
    RecoilStore.shared.reset()
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
