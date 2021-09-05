#if canImport(Combine)
import Combine
#endif

public struct RecoilCallbackContext {
    public let get = Getter()
    public let set = Setter()
    public var store: (AnyCancellable) -> Void
}

public typealias Callback<R> = (RecoilCallbackContext) -> R
public func useRecoilCallback<Return>(_ fn: @escaping Callback<Return>) -> () -> Return {
    let hook = RecoilCallbackHook(callback: curryFirst(fn))
    return useHook(hook)
}

public typealias Callback1<P, R> = (RecoilCallbackContext, P) -> R
public func useRecoilCallback<P, R>(_ fn: @escaping Callback1<P, R>) -> (P) -> R {
    let hook = RecoilCallbackHook(callback: curryFirst(fn))
    return useHook(hook)
}

public typealias Callback2<P1, P2, R> = (RecoilCallbackContext, P1, P2) -> R
public func useRecoilCallback<P1, P2, R>(_ fn: @escaping Callback2<P1, P2, R>) -> (P1, P2) -> R {
    let hook = RecoilCallbackHook(callback: curryFirst(fn))
    return useHook(hook)
}

private struct RecoilCallbackHook<T>: Hook {
    var callback: CallbackRef<T>.ContextCallback
    var updateStrategy: HookUpdateStrategy?
    
    func makeState() -> CallbackRef<T> {
        CallbackRef(callback: callback)
    }
    
    func updateState(coordinator: Coordinator) {
        let refState = coordinator.state
        refState.update(newValue: callback)
    }

    func dispose(state: CallbackRef<T>) {
        state.dispose()
    }

    func value(coordinator: Coordinator) -> T {
        let ref = coordinator.state
        let callback = ref.makeCallback()
        let context = RecoilCallbackContext(store: ref.store)
        return callback(context)
    }
}

private final class CallbackRef<Value> {
    typealias ContextCallback = (RecoilCallbackContext) -> Value
    
    private var callback: ContextCallback
    private var cancellables: Set<AnyCancellable> = []
    
    init(callback: @escaping ContextCallback) {
        self.callback = callback
    }
    
    func makeCallback() -> ContextCallback {
        return { [unowned self] context in
            self.cancel()
            return self.callback(context)
        }
    }
    
    func store(_ cancelable: AnyCancellable) {
        cancellables.insert(cancelable)
    }
    
    func update(newValue: @escaping ContextCallback) {
        cancel()
        callback = newValue
    }
    
    func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func dispose() {
        cancel()
    }
}

public extension AnyCancellable {
    func store(in context: RecoilCallbackContext) {
        var cancellables: Set<AnyCancellable> = []
        
        store(in: &cancellables)
        
        cancellables.forEach {
            context.store($0)
        }
    }
}
