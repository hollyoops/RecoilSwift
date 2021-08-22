#if canImport(SwiftUI)
import SwiftUI
#endif

public func useRecoilValue<P: Equatable, Return: IRecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> Return.DataType {
    let hook = RecoilValueHook(initialValue: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilValue<Value: IRecoilValue>(_ initialState: Value) -> Value.DataType {
    useHook(RecoilValueHook(initialValue: initialState))
}

public func useRecoilState<P: Equatable, Return: IRecoilState>(_ value: ParametricRecoilValue<P, Return>) -> Binding<Return.DataType> {
    let hook = RecoilStateHook(initialValue: value.recoilValue,
                               updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilState<Value: IRecoilState> (_ initialState: Value) -> Binding<Value.DataType> {
    useHook(RecoilStateHook(initialValue: initialState))
}

private protocol RecoilHook: Hook where State == Ref<T> {
    associatedtype T: IRecoilValue
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

private struct RecoilValueHook<T: IRecoilValue>: RecoilHook {
    var initialValue: T
    var updateStrategy: HookUpdateStrategy?

    func value(coordinator: Coordinator) -> T.DataType {
        coordinator.state.value.wrappedData
    }
}

private struct RecoilStateHook<T: IRecoilState>: RecoilHook {
    var initialValue: T
    var updateStrategy: HookUpdateStrategy?
    
    func value(coordinator: Coordinator) -> Binding<T.DataType> {
        Binding(
            get: {
                coordinator.state.value.wrappedData
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

