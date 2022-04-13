import Combine
import Foundation

@testable import RecoilSwift

struct TestConfig {
  static let expectation_wait_seconds = 0.3
  static let mock_async_wait_nanoseconds: UInt64 = 100_000_000
  static let mock_async_wait_seconds = 0.3
}

struct MockAPI {
  static func makeCombine<T>(result: Result<T, Error>, delay: Double) -> AnyPublisher<T, Error> {
    Deferred {
      Future { promise in
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          promise(result)
        }
      }
    }.eraseToAnyPublisher()
  }
  
  static func makeAsync<T>(value: T, delay: UInt64) async -> T {
    try? await Task.sleep(nanoseconds: delay)
    return value
  }
}

func makeSelector<T>(error: Error, type: T.Type) -> RecoilSwift.Selector<T> {
  selector { get throws -> T in
    throw error
  }
}

func makeCombineSelector<T>(
  value: T,
  delayInSeconds: Double = TestConfig.mock_async_wait_seconds
) -> AsyncSelector<T, Error> {
  selector { _ in
    MockAPI.makeCombine(result: .success(value), delay: delayInSeconds)
  }
}

func makeCombineSelector<T>(
  error: Error,
  type: T.Type,
  delayInSeconds: Double = TestConfig.mock_async_wait_seconds
) -> AsyncSelector<T, Error> {
  selector { get -> AnyPublisher<T, Error> in
    MockAPI.makeCombine(result: .failure(error), delay: delayInSeconds)
  }
}

func makeAsyncSelector<T>(
  value: T,
  delayInNanoSecounds: UInt64 = TestConfig.mock_async_wait_nanoseconds
) -> AsyncSelector<T, Error> {
  selector { _ in
    await MockAPI.makeAsync(value: value, delay: delayInNanoSecounds)
  }
}

func makeAsyncSelector<T>(
  error: Error,
  type: T.Type,
  delayInNanoSecounds: UInt64 = TestConfig.mock_async_wait_nanoseconds
) -> AsyncSelector<T, Error> {
  selector { get async throws -> T in
    try? await Task.sleep(nanoseconds: TestConfig.mock_async_wait_nanoseconds)
    throw error
  }
}
