#if canImport(Combine)
import Combine
#endif

protocol PromiseLikeProtocol {
    @discardableResult
    func then<T>(_ cb: @escaping (T) -> Void) -> Self
    
    @discardableResult
    func finally(_ cb: @escaping () -> Void) -> Self
    
    @discardableResult
    func `catch`<E: Error>(_ cb: @escaping (E) -> Void) -> Self
}

protocol LoaderProtocol {
    func cancel()
    
    func run(context: GetterFunction) -> Void
    
    func toPromise() -> PromiseLikeProtocol
}

class AbstractLoader<Value: Equatable>: LoaderProtocol, PromiseLikeProtocol {
    typealias SuccuessCallback<T> = (T) -> Void
    typealias FinallyCallback = () -> Void
    typealias ErrorCallback = (Error) -> Void
    
    private var successCBs: [SuccuessCallback<Value>] = []
    private var finallyCBs: [FinallyCallback] = []
    private var failureCBs: [ErrorCallback] = []
    
    @discardableResult
    func then<T>(_ cb: @escaping (T) -> Void) -> Self {
        if let newCB = cb as? SuccuessCallback<Value> {
            successCBs.append(newCB)
        }
        return self
    }
    
    @discardableResult
    func finally(_ cb: @escaping () -> Void) -> Self {
        finallyCBs.append(cb)
        return self
    }
    
    @discardableResult
    func `catch`<E: Error>(_ cb: @escaping (E) -> Void) -> Self {
        if let newCB = cb as? ErrorCallback {
            failureCBs.append(newCB)
        }
        
        return self
    }
    
    func run(context: GetterFunction) {
        fatalError("should implement this")
    }
    
    func cancel() {
         reset()
    }
    
    func toPromise() -> PromiseLikeProtocol {
        self
    }
    
    fileprivate func fireSuccess(_ value: Value) {
        successCBs.forEach { $0(value) }
    }
    
    fileprivate func fireError(_ e: Error) {
        failureCBs.forEach { $0(e) }
    }
    
    fileprivate func fireFinish() {
        finallyCBs.forEach { $0() }
        reset()
    }
    
    private func reset() {
        finallyCBs = []
        successCBs = []
        failureCBs = []
    }
}

class ValueLoader<T: Equatable>: AbstractLoader<T> {
    private var body: GetBody<T>
    
    init(_ syncBody: @escaping GetBody<T>) {
        body = syncBody
    }
    
    override func run(context: GetterFunction) {
        do {
            let value = try body(context)
            fireSuccess(value)
            fireFinish()
        } catch {
            fireError(error)
        }
    }
}

@available(iOS 13, *)
class CombineLoader<T: Equatable, Failure: Error>: AbstractLoader<T> {
    private var body: AsyncGetBody<T, Failure>
    private var cancellable: AnyCancellable?
    
    init(_ asyncBody: @escaping AsyncGetBody<T, Failure>) {
        body = asyncBody
    }

    override func cancel() {
        super.cancel()
        cancellable?.cancel()
    }
    
    override func run(context: GetterFunction) {
        do {
            watch(try body(context))
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
