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
  
}
