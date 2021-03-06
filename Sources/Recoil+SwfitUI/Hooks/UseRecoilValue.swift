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

protocol RecoilHook: Hook where State == Ref<T> {
    associatedtype T: RecoilValue
    var initialValue: T { get }
}

extension RecoilHook {
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
