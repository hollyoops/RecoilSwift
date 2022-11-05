import XCTest

@testable import RecoilSwift

class KeyedSubscriberTests: XCTestCase {

    // Dummy Subscriber class for testing purposes
    class DummySubscriber: Subscriber {
        var valueDidChangeCalled = false

        func valueDidChange() {
            valueDidChangeCalled = true
        }
    }

    func testShouldReturnTrueWhenIdsAreEqual() {
        let subscriber = DummySubscriber()
        let keyedSubscriber1 = KeyedSubscriber(subscriber: subscriber)
        let keyedSubscriber2 = KeyedSubscriber(subscriber: subscriber)

        XCTAssertTrue(keyedSubscriber1 == keyedSubscriber2)
    }

    func testShouldReturnFalseWhenIdsAreNotEqual() {
        let subscriber1 = DummySubscriber()
        let subscriber2 = DummySubscriber()
        let keyedSubscriber1 = KeyedSubscriber(subscriber: subscriber1)
        let keyedSubscriber2 = KeyedSubscriber(subscriber: subscriber2)

        XCTAssertFalse(keyedSubscriber1 == keyedSubscriber2)
    }

    func testShouldReturnConsistentHashWhenCalledMultipleTimes() {
        let subscriber = DummySubscriber()
        let keyedSubscriber = KeyedSubscriber(subscriber: subscriber)

        let initialHash = keyedSubscriber.hashValue
        XCTAssertEqual(initialHash, keyedSubscriber.hashValue)
    }

    func testShouldCallValueDidChangeOnSubscriber() {
        let subscriber = DummySubscriber()
        let keyedSubscriber = KeyedSubscriber(subscriber: subscriber)

        keyedSubscriber.valueDidChange()

        XCTAssertTrue(subscriber.valueDidChangeCalled)
    }
}
