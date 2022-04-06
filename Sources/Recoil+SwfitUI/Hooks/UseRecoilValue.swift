#if canImport(SwiftUI)
import SwiftUI
#endif
import Hooks

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - value: Selectors which with user-defined parameters
/// - Returns: return a readable inner value that wrapped in recoil state.
/// if the state is async state, it return will `'value?'`, otherwise it return `'value'`
public func useRecoilValue<P: Equatable, Return: RecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> Return.DataType {
    let hook = RecoilValueHook(initialValue: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - value: a recoil state (`atom` or `selector`)
/// - Returns: return a readable inner value that wrapped in recoil state.
/// if the state is async state, it return will `'value?'`, otherwise it return `'value'`
public func useRecoilValue<Value: RecoilValue>(_ initialState: Value) -> Value.DataType {
    useHook(RecoilValueHook(initialValue: initialState))
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - initialState: a writeable recoil state wrapper which with a `recoil state` and `user-defined parameters`
/// - Returns: return a ``Binding`` value that wrapped in recoil state.
/// if the state is async state, it return will `'Binding<value?>'`, otherwise it return `'Binding<value>'`
public func useRecoilState<P: Equatable, Return: RecoilState>(_ value: ParametricRecoilValue<P, Return>) -> Binding<Return.DataType> {
    let hook = RecoilStateHook(initialValue: value.recoilValue,
                               updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - initialState: a writeable recoil state(`atom` or writeable `selector`)
/// - Returns: return a ``Binding`` value that wrapped in recoil state.
/// if the state is async state, it return will `'Binding<value?>'`, otherwise it return `'Binding<value>'`
public func useRecoilState<Value: RecoilState> (_ initialState: Value) -> Binding<Value.DataType> {
  let hook = RecoilStateHook(initialValue: initialState,
                             updateStrategy: .preserved(by: initialState.key))
  return useHook(hook)
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector wrapper which with user-defined parameters
/// - Returns: return a loadable object that contains loading informations
public func useRecoilValueLoadable<P: Equatable, Return: RecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> Return.LoadableType {
    let hook = RecoilLoadableValueHook(initialValue: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector
/// - Returns: return a loadable object that contains loading informations
public func useRecoilValueLoadable<Value: RecoilValue>(_ value: Value) -> Value.LoadableType {
    useHook(RecoilLoadableValueHook(initialValue: value))
}

private struct RecoilLoadableValueHook<T: RecoilValue>: RecoilHook {
    var initialValue: T
    var updateStrategy: HookUpdateStrategy?

    func value(coordinator: Coordinator) -> T.LoadableType {
        Store.shared.getLoadable(for: coordinator.state.value) as! T.LoadableType
    }
}

private protocol RecoilHook: Hook where State == Ref<T> {
    associatedtype T: RecoilValue
    var initialValue: T { get }
}

private extension RecoilHook {
    func makeState() -> Ref<T> {
        Ref(initialState: initialValue)
    }
    
    func updateState(coordinator: Coordinator) {
        let updateView = coordinator.updateView
        let refState = coordinator.state
        refState.update(newValue: initialValue, viewUpdator: updateView)
    }

    func dispose(state: Ref<T>) {
        state.dispose()
    }
}

private struct RecoilValueHook<T: RecoilValue>: RecoilHook {
    var initialValue: T
    var updateStrategy: HookUpdateStrategy?

    func value(coordinator: Coordinator) -> T.DataType {
        Getter()(coordinator.state.value)
    }
}

private struct RecoilStateHook<T: RecoilState>: RecoilHook {
    var initialValue: T
    var updateStrategy: HookUpdateStrategy?
    
    func value(coordinator: Coordinator) -> Binding<T.DataType> {
        Binding(
            get: {
                Getter()(coordinator.state.value)
            },
            set: { newState in
                assertMainThread()

                guard !coordinator.state.isDisposed else {
                    return
                }

                coordinator.state.value.update(with: newState)
            }
        )
    }
}

private final class Ref<Value: RecoilValue> {
    var value: Value {
        willSet { cancelTasks() }
    }
    
    var isDisposed = false
    var storeSubscriber: Subscriber?
    
    init(initialState: Value) {
        value = initialState
    }
    
    func update(newValue: Value, viewUpdator: @escaping () -> Void) {
        value = newValue
   
        let storeRef = Store.shared
        self.storeSubscriber = storeRef.addObserver(forKey: newValue.key) {
            viewUpdator()
        }
        
        let loadable = storeRef.getLoadable(for: newValue)
        if loadable.status == .initiated {
          loadable.load()
        }
    }
    
    func dispose() {
        isDisposed = true
        cancelTasks()
        // TODO: Remove dynamic recoil value in store?
    }
    
    private func cancelTasks() {
        storeSubscriber?.cancel()
        
        storeSubscriber = nil
    }
}

