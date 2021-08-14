#if canImport(Combine)
import Combine
#endif

@available(iOS 13.0, *)
public typealias CombineGetBody<T: Equatable, E: Error> = () throws -> AnyPublisher<T, E>

@available(iOS 13, *)
class CombineLoader<T: Equatable, Failure: Error>: AbstractLoader<T> {
    private var body: CombineGetBody<T, Failure>
    private var cancellable: AnyCancellable?
    
    init(_ asyncBody: @escaping CombineGetBody<T, Failure>) {
        body = asyncBody
    }

    override func cancel() {
        super.cancel()
        cancellable?.cancel()
    }
    
    override func run() {
        do {
            watch(try body())
        } catch {
            fireError(error)
        }
    }
    
    private func watch(_ publisher: AnyPublisher<T, Failure>) {
        cancellable = publisher.sink(receiveCompletion: { [weak self] in self?.loadingFinish($0) },
                       receiveValue: { [weak self] in self?.fireSuccess($0) })
    }
    
    private func loadingFinish(_ completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .failure(let error): fireError(error)
        case .finished: fireFinish()
        }
    }
}
