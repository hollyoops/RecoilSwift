import SwiftUI
import XCTest

@testable import RecoilSwift

final class AtomReadWriteTests: XCTestCase {
  struct TestModule  {
    static var stringAtom: Atom<String>!
  }
  
  override func setUp() {
    TestModule.stringAtom = atom { "rawValue" }
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
