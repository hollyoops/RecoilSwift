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
    _ value: RecoilParamNode<P, Return>
) -> Return.T? {
    let hook = RecoilValueHook(node: value.node,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

@MainActor
public func useRecoilValue<P: Equatable, Return: RecoilAsyncNode>(
    _ value: RecoilParamNode<P, Return>
) -> Return.T? {
    let hook = RecoilAsyncValueHook(node: value.node,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - value: a recoil state (`atom` or `selector`)
/// - Returns: return a readable inner value that wrapped in recoil state.
/// if the state is async state, it return will `'value?'`, otherwise it return `'value'`
@MainActor
public func useRecoilValue<Value: RecoilSyncNode>(_ initialState: Value) -> Value.T? {
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
    _ value: RecoilParamNode<P, Return>
) -> Binding<Return.T> {
    let hook = RecoilStateHook(node: value.node,
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
    @MainActor
    func makeState() -> Ref<T> {
        Ref(initialState: initialValue)
    }
    
    @MainActor
    func makeScopeContext(coordinator: Coordinator) -> ScopedRecoilContext {
        ScopedRecoilContext(
            store: coordinator.environment.store,
            cache: coordinator.state.cache,
            refresher: AnyViewRefreher(viewUpdator: coordinator.updateView))
    }
    
    @MainActor
    func getStoredContext(coordinator: Coordinator) -> ScopedRecoilContext {
        let refState = coordinator.state
        let ctx = refState.ctx ?? makeScopeContext(coordinator: coordinator)
        
        if refState.ctx == nil {
            refState.update(newValue: initialValue, context: ctx)
        }

        return ctx
    }
    
    @MainActor
    func updateState(coordinator: Coordinator) {
        let refState = coordinator.state
        refState.update(newValue: initialValue,
                        context: makeScopeContext(coordinator: coordinator))
    }

    @MainActor
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

    @MainActor
    func value(coordinator: Coordinator) -> Node.T? {
        let recoil = getStoredContext(coordinator: coordinator)
        return try? recoil.useThrowingValue(initialValue)
    }
}

private struct RecoilAsyncValueHook<Node: RecoilAsyncNode>: RecoilHook {
    let initialValue: Node
    let updateStrategy: HookUpdateStrategy?
    
    init(node: Node, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = node
        self.updateStrategy = updateStrategy
    }
    
    @MainActor
    func value(coordinator: Coordinator) -> Node.T? {
        let recoil = getStoredContext(coordinator: coordinator)
        return recoil.useValue(initialValue)
    }
}

private struct RecoilStateHook<Node: RecoilMutableSyncNode>: RecoilHook {
    let initialValue: Node
    let updateStrategy: HookUpdateStrategy?
    
    init(node: Node, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = node
        self.updateStrategy = updateStrategy
    }
    
    @MainActor
    func value(coordinator: Coordinator) -> Binding<Node.T> {
        let recoil = getStoredContext(coordinator: coordinator)
        return recoil.useUnsafeBinding(initialValue)
    }
}
