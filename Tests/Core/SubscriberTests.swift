import SwiftUI
import XCTest

@testable import RecoilSwift

final class SubscriberTests: XCTestCase {
  func testShouldSubscriberWillEqual() {
    let sub1 = Subscriber { }
    let sub2 = sub1
    XCTAssertEqual(sub1, sub2)
  }
  
  func testShouldSubscriberNotEqual() {
    let sub1 = Subscriber { }
    let sub2 = Subscriber { }
    XCTAssertNotEqual(sub1, sub2)
  }
}
