#if canImport(Combine)
import Combine

public enum AnyPublisherError: Error {
    case finishedWithoutValue
}

public extension AnyPublisher {
    func async() async throws -> Output {
        let cancellableActor = CancellableActor()
        return try await withTaskCancellationHandler(operation: {
            try Task.checkCancellation()
            
            return try await withCheckedThrowingContinuation { continuation in
                guard !Task.isCancelled else {
                    continuation.resume(throwing: CancellationError())
                    return
                }
                
                var didSendValue = false
                let cancellable = self.first()
                    .handleEvents(receiveCancel: {
                        continuation.resume(throwing: CancellationError())
                    })
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                if !didSendValue {
                                    continuation.resume(throwing: AnyPublisherError.finishedWithoutValue)
                                }
                                break
                            case let .failure(error):
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { value in
                            didSendValue = true
                            continuation.resume(returning: value)
                        }
                    )
                Task {
                    await cancellableActor.setCancellable(cancellable)
                }
            }
        }, onCancel: {
            Task {
                await cancellableActor.cancel()
            }
        })
    }
}

#endif

actor CancellableActor {
    private var cancellable: AnyCancellable?
    
    func setCancellable(_ cancellable: AnyCancellable) {
        self.cancellable = cancellable
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}
