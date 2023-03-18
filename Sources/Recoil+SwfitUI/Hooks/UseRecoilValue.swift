#if canImport(SwiftUI)
import SwiftUI
#endif
import Hooks

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - value: Selectors which with user-defined parameters
/// - Returns: return a readable inner value that wrapped in recoil state.
/// if the state is async state, it return will `'value?'`, otherwise it return `'value'`
@MainActor
public func useRecoilValue<P: Equatable, Return: RecoilSyncNode>(
    _ value: ParametricRecoilValue<P, Return>
) -> Return.T {
    let hook = RecoilValueHook(node: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

@MainActor
public func useRecoilValue<P: Equatable, Return: RecoilAsyncNode>(
    _ value: ParametricRecoilValue<P, Return>
) -> Return.T? {
    let hook = RecoilAsyncValueHook(node: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - value: a recoil state (`atom` or `selector`)
/// - Returns: return a readable inner value that wrapped in recoil state.
/// if the state is async state, it return will `'value?'`, otherwise it return `'value'`
@MainActor
public func useRecoilValue<Value: RecoilSyncNode>(_ initialState: Value) -> Value.T {
    useHook(RecoilValueHook(node: initialState))
}

@MainActor
public func useRecoilValue<Value: RecoilAsyncNode>(_ initialState: Value) -> Value.T? {
    useHook(RecoilAsyncValueHook(node: initialState))
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - initialState: a writeable recoil state wrapper which with a `recoil state` and `user-defined parameters`
/// - Returns: return a ``Binding`` value that wrapped in recoil state.
/// if the state is async state, it return will `'Binding<value?>'`, otherwise it return `'Binding<value>'`
@MainActor
public func useRecoilState<P: Equatable, Return: RecoilMutableSyncNode>(
    _ value: ParametricRecoilValue<P, Return>
) -> Binding<Return.T> {
    let hook = RecoilStateHook(node: value.recoilValue,
                               updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - initialState: a writeable recoil state(`atom` or writeable `selector`)
/// - Returns: return a ``Binding`` value that wrapped in recoil state.
/// if the state is async state, it return will `'Binding<value?>'`, otherwise it return `'Binding<value>'`
@MainActor
public func useRecoilState<Value: RecoilMutableSyncNode> (_ initialState: Value) -> Binding<Value.T> {
  let hook = RecoilStateHook(node: initialState,
                             updateStrategy: .preserved(by: initialState.key))
  return useHook(hook)
}

protocol RecoilHook: Hook {
    associatedtype T
    var initialValue: T { get }
}

extension RecoilHook where State == Ref<T> {
    func makeState() -> Ref<T> {
        Ref(initialState: initialValue)
    }
    
    func makeScopeContext(coordinator: Coordinator) -> ScopedRecoilContext {
        ScopedRecoilContext(
            store: coordinator.environment.store,
            cache: coordinator.state.cache,
            refresher: AnyViewRefreher(viewUpdator: coordinator.updateView))
    }
    
    func getStoredContext(coordinator: Coordinator) -> ScopedRecoilContext {
        let refState = coordinator.state
        let ctx = refState.ctx ?? makeScopeContext(coordinator: coordinator)
        
        if refState.ctx == nil {
            refState.update(newValue: initialValue, context: ctx)
        }

        return ctx
    }
    
    func updateState(coordinator: Coordinator) {
        let refState = coordinator.state
        refState.update(newValue: initialValue,
                        context: makeScopeContext(coordinator: coordinator))
    }

    func dispose(state: Ref<T>) {
        state.dispose()
    }
}

private struct RecoilValueHook<Node: RecoilSyncNode>: RecoilHook {
    let initialValue: Node
    let updateStrategy: HookUpdateStrategy?
    
    init(node: Node, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = node
        self.updateStrategy = updateStrategy
    }

    func value(coordinator: Coordinator) -> T.T {
        let ctx = getStoredContext(coordinator: coordinator)
        return ctx.useRecoilValue(initialValue)
    }
}

private struct RecoilAsyncValueHook<Node: RecoilAsyncNode>: RecoilHook {
    let initialValue: Node
    let updateStrategy: HookUpdateStrategy?
    
    init(node: Node, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = node
        self.updateStrategy = updateStrategy
    }

    func value(coordinator: Coordinator) -> Node.T? {
        let ctx = getStoredContext(coordinator: coordinator)
        return ctx.useRecoilValue(initialValue)
    }
}

private struct RecoilStateHook<Node: RecoilMutableSyncNode>: RecoilHook {
    let initialValue: Node
    let updateStrategy: HookUpdateStrategy?
    
    init(node: Node, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = node
        self.updateStrategy = updateStrategy
    }
    
    func value(coordinator: Coordinator) -> Binding<Node.T> {
        let ctx = getStoredContext(coordinator: coordinator)
        let bindableValue = ctx.useRecoilState(initialValue)
        return Binding(
            get: bindableValue.get,
            set: { newState in
                assertMainThread()

                guard !coordinator.state.isDisposed else {
                    return
                }

                bindableValue.set(newState)
            }
        )
    }
}
