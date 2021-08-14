#if canImport(Combine)
import Combine
#endif

internal protocol PromiseLikeProtocol {
    @discardableResult
    func then<T>(_ cb: @escaping (T) -> Void) -> Self
    
    @discardableResult
    func finally(_ cb: @escaping () -> Void) -> Self
    
    @discardableResult
    func `catch`<E: Error>(_ cb: @escaping (E) -> Void) -> Self
}

internal protocol LoaderProtocol {
    func cancel()
    
    func run() -> Void
    
    func toPromise() -> PromiseLikeProtocol
}

internal class AbstractLoader<Value: Equatable>: LoaderProtocol, PromiseLikeProtocol {
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
    
    func run() {
        fatalError("should implement this")
    }
    
    func cancel() {
         reset()
    }
    
    func toPromise() -> PromiseLikeProtocol {
        self
    }
    
    func fireSuccess(_ value: Value) {
        successCBs.forEach { $0(value) }
    }
    
    func fireError(_ e: Error) {
        failureCBs.forEach { $0(e) }
    }
    
    func fireFinish() {
        finallyCBs.forEach { $0() }
        reset()
    }
    
    private func reset() {
        finallyCBs = []
        successCBs = []
        failureCBs = []
    }
}
