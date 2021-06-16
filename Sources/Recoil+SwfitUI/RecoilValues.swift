#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
@propertyWrapper public struct RecoilValue<T: IRecoilValue>: DynamicProperty {
    @StateObject private var state: RefreshableState<T>
    
    public init(_ value: T) {
        _state =  StateObject(wrappedValue: RefreshableState(value))
    }
    
    public var wrappedValue: T.WrappedValue {
        state.wrappedValue
    }
}

@available(iOS 14, *)
@propertyWrapper public struct RecoilState<T: IRecoilState>: DynamicProperty {
    @StateObject private var state: RefreshableState<T>

    public init(_ value: T) {
        _state =  StateObject(wrappedValue:RefreshableState(value))
    }

    public var wrappedValue: T.WrappedValue {
        get { state.wrappedValue }
        nonmutating set {
            state.update(newValue)
        }
    }

    public var projectedValue: Binding<T.WrappedValue> {
        Binding(
            get: { state.wrappedValue },
            set: { newValue in state.update(newValue) }
        )
    }
}

@available(iOS 13, *)
private class RefreshableState<State: IRecoilValue>: ObservableObject {
    private let recoilValue: State
    
    var wrappedValue: State.WrappedValue {
        recoilValue.wrappedValue
    }
    
    init(_ state: State) {
        recoilValue = state
        _ = state.observe {
            self.notifyUpdate()
        }
        recoilValue.initNode()
    }
    
    func update(_ newValue: State.WrappedValue) where State: IRecoilState {
        recoilValue.update(newValue)
    }
    
    private func notifyUpdate() {
        objectWillChange.send()
    }
}
