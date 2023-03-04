import Combine
import Foundation

@testable import RecoilSwift

struct TestConfig {
  static let expectation_wait_seconds = 0.3
  static let mock_async_wait_nanoseconds: UInt64 = 500_000_00
  static let mock_async_wait_seconds = 0.05
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

func makeCombineAtom<T>(
  value: T,
  delayInSeconds: Double = TestConfig.mock_async_wait_seconds
) -> AsyncAtom<T> {
  atom {
    MockAPI.makeCombine(result: .success(value), delay: delayInSeconds)
  }
}

func makeCombineAtom<T>(
  error: Error,
  type: T.Type,
  delayInSeconds: Double = TestConfig.mock_async_wait_seconds
) -> AsyncAtom<T> {
  atom {
    MockAPI.makeCombine(result: .failure(error), delay: delayInSeconds)
  }
}

func makeAsyncAtom<T>(
  value: T,
  delayInNanoSecounds: UInt64 = TestConfig.mock_async_wait_nanoseconds
) -> AsyncAtom<T> {
  atom { () async -> T in
    await MockAPI.makeAsync(value: value, delay: delayInNanoSecounds)
  }
}

func makeAsyncAtom<T>(
  error: Error,
  type: T.Type,
  delayInNanoSecounds: UInt64 = TestConfig.mock_async_wait_nanoseconds
) -> AsyncAtom<T> {
  atom { () async throws -> T in
    try? await Task.sleep(nanoseconds: TestConfig.mock_async_wait_nanoseconds)
    throw error
  }
}

func makeCombineSelector<T>(
  value: T,
  delayInSeconds: Double = TestConfig.mock_async_wait_seconds
) -> AsyncSelector<T> {
  selector { _ in
    MockAPI.makeCombine(result: .success(value), delay: delayInSeconds)
  }
}

func makeCombineSelector<T>(
  error: Error,
  type: T.Type,
  delayInSeconds: Double = TestConfig.mock_async_wait_seconds
) -> AsyncSelector<T> {
  selector { accessor  -> AnyPublisher<T, Error> in
    MockAPI.makeCombine(result: .failure(error), delay: delayInSeconds)
  }
}

func makeAsyncSelector<T>(
  value: T,
  delayInNanoSecounds: UInt64 = TestConfig.mock_async_wait_nanoseconds
) -> AsyncSelector<T> {
  selector { _ in
    await MockAPI.makeAsync(value: value, delay: delayInNanoSecounds)
  }
}

func makeAsyncSelector<T>(
  error: Error,
  type: T.Type,
  delayInNanoSecounds: UInt64 = TestConfig.mock_async_wait_nanoseconds
) -> AsyncSelector<T> {
  selector { get async throws -> T in
    try? await Task.sleep(nanoseconds: TestConfig.mock_async_wait_nanoseconds)
    throw error
  }
}
