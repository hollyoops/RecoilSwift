#if canImport(Combine)
import Combine
#endif

@available(iOS 13.0, *)
typealias CombineLoaderBody<T: Equatable, E: Error> = CombineLoader<T, E>.Body

@available(iOS 13, *)
class CombineLoader<T: Equatable, Failure: Error>: AbstractLoader<T> {
    typealias Body = () throws -> AnyPublisher<T, Failure>

    private var body: Body
    private var cancellable: AnyCancellable?

    init(_ asyncBody: @escaping Body) {
        body = asyncBody
    }

    override func cancel() {
        if let c = cancellable {
          c.cancel()
          cancellable = nil
          fireFinish()
        }
      
        super.cancel()
    }

    override func run() {
        do {
            watch(try body())
        } catch {
            fireError(error)
            fireFinish()
        }
    }

    private func watch(_ publisher: AnyPublisher<T, Failure>) {
        cancellable = publisher.sink(receiveCompletion: { [weak self] in self?.loadingFinish($0) },
                                     receiveValue: { [weak self] in self?.fireSuccess($0) })
    }

    private func loadingFinish(_ completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .failure(let error):
          fireError(error)
          fireFinish()
        case .finished: fireFinish()
        }
    }
}
