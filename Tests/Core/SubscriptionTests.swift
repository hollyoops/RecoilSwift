import XCTest

@testable import RecoilSwift

final class SubscriberTests: XCTestCase {
    func testShouldCallUnsubscribeBlock() {
        var isCalled = false
        let subscription = Subscription {
            isCalled = true
        }
        subscription.unsubscribe()
        XCTAssertTrue(isCalled)
    }
}
