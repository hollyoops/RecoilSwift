#if canImport(Combine)
import Combine
#endif
import Hooks

public struct RecoilCallbackContext {
    public let get: Getter
    public let set: Setter
    public var store: (AnyCancellable) -> Void
}

/// A hook provide an API for your callbacks to work with Recoil state. Diffrent with other hooks, the hook don't load state, until you manually call it. Asynchronously read Recoil state without subscribing a component to re-render if the atom or selector is updated.
/// - Parameters:
///   - fn: A function that you want to access the Recoil state
/// - Returns: return a callback function that can trigger state update after call it
public typealias Callback<R> = (RecoilCallbackContext) -> R
public func useRecoilCallback<Return>(_ fn: @escaping Callback<Return>) -> () -> Return {
    let hook = RecoilCallbackHook(callback: curryFirst(fn))
    return useHook(hook)
}

/// A hook provide an API for your callbacks to work with Recoil state. Diffrent with other hooks, the hook don't load state, until you manually call it. Asynchronously read Recoil state without subscribing a component to re-render if the atom or selector is updated.
/// - Parameters:
///   - fn: A function that you want to access the Recoil state with one user-defined parameter
/// - Returns: return a callback function that can trigger state update after call it
public typealias Callback1<P, R> = (RecoilCallbackContext, P) -> R
public func useRecoilCallback<P, R>(_ fn: @escaping Callback1<P, R>) -> (P) -> R {
    let hook = RecoilCallbackHook(callback: curryFirst(fn))
    return useHook(hook)
}

/// A hook provide an API for your callbacks to work with Recoil state. Diffrent with other hooks, the hook don't load state, until you manually call it. Asynchronously read Recoil state without subscribing a component to re-render if the atom or selector is updated.
/// - Parameters:
///   - fn: A function that you want to access the Recoil state with two user-defined parameters
/// - Returns: return a callback function that can trigger state update after call it
public typealias Callback2<P1, P2, R> = (RecoilCallbackContext, P1, P2) -> R
public func useRecoilCallback<P1, P2, R>(_ fn: @escaping Callback2<P1, P2, R>) -> (P1, P2) -> R {
    let hook = RecoilCallbackHook(callback: curryFirst(fn))
    return useHook(hook)
}

typealias ContextCallback<T> = (RecoilCallbackContext) -> T

private struct RecoilCallbackHook<T>: RecoilHook {
    var initialValue: ContextCallback<T>
    var updateStrategy: HookUpdateStrategy?
    
    init(callback: @escaping ContextCallback<T>, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = callback
        self.updateStrategy = updateStrategy
    }

    func value(coordinator: Coordinator) -> T {
        let ctx = getStoredContext(coordinator: coordinator)
        return ctx.useRecoilCallback(initialValue)()
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
