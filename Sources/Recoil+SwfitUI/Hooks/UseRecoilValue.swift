#if canImport(SwiftUI)
import SwiftUI
#endif

public func useRecoilValue<P: Equatable, Return: IRecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> Return.WrappedValue {
    let hook = RecoilValueHook(initialValue: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilValue<Value: IRecoilValue>(_ initialState: Value) -> Value.WrappedValue {
    useHook(RecoilValueHook(initialValue: initialState))
}

public func useRecoilState<P: Equatable, Return: IRecoilState>(_ value: ParametricRecoilValue<P, Return>) -> Binding<Return.WrappedValue> {
    let hook = RecoilStateHook(initialValue: value.recoilValue,
                               updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilState<Value: IRecoilState> (_ initialState: Value) -> Binding<Value.WrappedValue> {
    useHook(RecoilStateHook(initialValue: initialState))
}

private struct RecoilValueHook<Value: IRecoilValue>: Hook {
    let initialValue: Value
    var updateStrategy: HookUpdateStrategy? = .once

    func makeState() -> Ref<Value> {
        Ref(initialState: initialValue)
    }

    func value(coordinator: Coordinator) -> Value.WrappedValue {
        coordinator.state.value.wrappedValue
    }
    
    func updateState(coordinator: Coordinator) {
        let updateView = coordinator.updateView
        coordinator.state.update(newValue: initialValue, viewUpdator: updateView)
    }

    func dispose(state: Ref<Value>) {
        state.dispose()
    }
}

private struct RecoilStateHook<Value: IRecoilState>: Hook {
    let initialValue: Value
    var updateStrategy: HookUpdateStrategy? = .once

    func makeState() -> Ref<Value> {
        Ref(initialState: initialValue)
    }
    
    func value(coordinator: Coordinator) -> Binding<Value.WrappedValue> {
        Binding(
            get: {
                coordinator.state.value.wrappedValue
            },
            set: { newState in
                assertMainThread()

                guard !coordinator.state.isDisposed else {
                    return
                }

                coordinator.state.value.update(newState)
                coordinator.updateView()
            }
        )
    }
    
    func updateState(coordinator: Coordinator) {
        let updateView = coordinator.updateView
        coordinator.state.update(newValue: initialValue, viewUpdator: updateView)
    }

    func dispose(state: Ref<Value>) {
        state.dispose()
    }
}

private final class Ref<Value: IRecoilValue> {
    var value: Value
    var isDisposed = false
    var cancellable: ICancelable?
    
    init(initialState: Value) {
        value = initialState
    }
    
    func update(newValue: Value, viewUpdator: @escaping () -> Void) {
        cancellable?.cancel()
        value = newValue
        value.mount()
        cancellable = value.observe {
            viewUpdator()
        }
    }
    
    func dispose() {
        isDisposed = true
        cancellable?.cancel()
        cancellable = nil
    }
}

