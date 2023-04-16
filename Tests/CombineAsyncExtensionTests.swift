import XCTest
import Combine
import RecoilSwiftTestKit

@testable import RecoilSwift

class AnyPublisherExtensionTests: XCTestCase {
    func testAsync_shouldCompleteNormally_whenPublisherEmitsValue() async {
        let value = "Hello, world!"
        let publisher = Just(value).eraseToAnyPublisher()
        do {
            let result = try await publisher.async()
            XCTAssertEqual(result, value, "Expected received value to be \(value)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAsync_shouldThrowError_whenPublisherFinishesWithoutEmittingValue() async {
        let publisher = Empty<String, Never>().eraseToAnyPublisher()
        do {
            let _ = try await publisher.async()
            XCTFail("Expected error but received value")
        } catch {
            XCTAssertEqual(error as? AnyPublisherError, .finishedWithoutValue, "Expected error to be .finishedWithoutValue")
        }
    }

    func testAsync_shouldThrowError_whenPublisherEmitsError() async {
        let error = TestError.someError
        let publisher = Fail<String, TestError>(error: error).eraseToAnyPublisher()
        do {
            let _ = try await publisher.async()
            XCTFail("Expected error but received value")
        } catch {
            XCTAssertEqual(error as? TestError, .someError, "Expected error to be .someError")
        }
    }

    func testAsync_shouldThrowCancellationError_whenCancelled() async {
        let publisher = PassthroughSubject<String, Never>().eraseToAnyPublisher()
        let task = Task {
            do {
                let _ = try await publisher.async()
                XCTFail("Expected cancellation error but completed normally")
            } catch {
                let isCanceled = error is CancellationError
                XCTAssertEqual(isCanceled, true)
            }
        }

        // Simulate a delay, then cancel the task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            task.cancel()
        }

        await task.value
    }
}

enum TestError: Error {
    case someError
}
