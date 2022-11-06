#if canImport(Combine)
import Combine
#endif

public typealias CombineGetFunc<T: Equatable, E: Error> = (Getter) throws -> AnyPublisher<T, E>

public typealias CombineGetBodyFunc<T: Equatable, E: Error> = () throws -> AnyPublisher<T, E>

class CombineGetBody<T: Equatable, Failure: Error>: AsyncEvaluator {
    typealias Body = CombineGetBodyFunc<T, Failure>

    private var body: Body
    private var cancellable: AnyCancellable?
    
    init(_ asyncBody: @escaping Body) {
        body = asyncBody
    }

    func evaluate() async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
//            var cancellable: AnyCancellable?
//            continuation.onTermination = {
//                cancellable
//            }

            do {
                var finishedWithoutValue = true
                cancellable = try body()
                    .first()
                    .sink { result in
                        switch result {
                        case .finished:
                            if finishedWithoutValue {
                                continuation.resume(throwing: EvaluatorError.finishedWithoutValue)
                            }
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    } receiveValue: { value in
                        finishedWithoutValue = false
                        continuation.resume(with: .success(value))
                    }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
