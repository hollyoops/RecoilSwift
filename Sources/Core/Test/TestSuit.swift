import XCTest

public class TestSuit {
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func expect<T: Equatable>(_ actual: T) -> Expectation<T> {
        return Expectation(testSuit: self, actual: actual)
    }
}

public class Expectation<T: Equatable> {
    let testSuit: TestSuit
    let actual: T
    
    init(testSuit: TestSuit, actual: T) {
        self.testSuit = testSuit
        self.actual = actual
    }
    
    public func equalTo(_ expected: T) {
        if actual == expected {
            testSuit.expectation.fulfill()
        }
    }
}
