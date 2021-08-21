#if canImport(SwiftUI)
import SwiftUI
#endif

public func useRecoilValue<Value: IRecoilValue>(_ initialState: Value) -> Value.WrappedValue {
    useHook(RecoilValueHook(initialValue: initialState))
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
        coordinator.state.value.mount()
    }

    func dispose(state: Ref<Value>) {
        state.isDisposed = true
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
        coordinator.state.value.mount()
    }

    func dispose(state: Ref<Value>) {
        state.isDisposed = true
    }
}

private final class Ref<Value> {
    var value: Value
    var isDisposed = false
    
    init(initialState: Value) {
        value = initialState
    }
}

