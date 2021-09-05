#if canImport(SwiftUI)
import SwiftUI
#endif

public func useRecoilValue<P: Equatable, Return: RecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> Return.DataType {
    let hook = RecoilValueHook(initialValue: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilValue<Value: RecoilValue>(_ initialState: Value) -> Value.DataType {
    useHook(RecoilValueHook(initialValue: initialState))
}

public func useRecoilState<P: Equatable, Return: RecoilState>(_ value: ParametricRecoilValue<P, Return>) -> Binding<Return.DataType> {
    let hook = RecoilStateHook(initialValue: value.recoilValue,
                               updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilState<Value: RecoilState> (_ initialState: Value) -> Binding<Value.DataType> {
    useHook(RecoilStateHook(initialValue: initialState))
}

public func useRecoilValueLoadable<P: Equatable, Return: RecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> Return.LoadableType {
    let hook = RecoilLoadableValueHook(initialValue: value.recoilValue,
                                updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

public func useRecoilValueLoadble<Value: RecoilValue>(_ value: Value) -> Value.LoadableType {
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
                coordinator.updateView()
            }
        )
    }
}

private final class Ref<Value: RecoilValue> {
    var value: Value {
        willSet { cancelTasks() }
    }
    
    var isDisposed = false
    var cancellable: RecoilCancelable?
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
        loadable.load()
    }
    
    func dispose() {
        isDisposed = true
        cancelTasks()
    }
    
    private func cancelTasks() {
        cancellable?.cancel()
        storeSubscriber?.cancel()
        
        cancellable = nil
        storeSubscriber = nil
    }
}
