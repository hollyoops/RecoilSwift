import Combine
import Foundation

@testable import RecoilSwift

struct TestConfig {
    static let expectation_wait_seconds = 0.3
    static let mock_async_wait_nanoseconds: UInt64 = 500_000_00
    static let mock_async_wait_seconds = 0.05
}

struct MockAPI {
    static func makeCombine<T>(
        result: Result<T, Error>,
        delay: Double = Double(TestConfig.mock_async_wait_nanoseconds)
    ) -> AnyPublisher<T, Error> {
        Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    promise(result)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    static func makeAsync<T>(
        value: T,
        delay: UInt64 = TestConfig.mock_async_wait_nanoseconds
    ) async -> T {
        try? await Task.sleep(nanoseconds: delay)
        return value
    }
}
