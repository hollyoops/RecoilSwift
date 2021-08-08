#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14, *)
@propertyWrapper public struct RecoilValue<T: IRecoilValue>: DynamicProperty {
    @StateObject private var state: RefreshableWrapper<T>
    
    public init(_ value: T) {
        _state = StateObject(wrappedValue: RefreshableWrapper(from: value))
    }
    
    public var wrappedValue: T.WrappedValue {
        state.wrappedValue
    }
    
    public var loadableState: LoadableState {
        state
    }
}

@available(iOS 14, *)
@propertyWrapper public struct RecoilState<T: IRecoilState>: DynamicProperty {
    @StateObject private var state: RefreshableWrapper<T>

    public init(_ value: T) {
        _state = StateObject(wrappedValue:RefreshableWrapper(from: value))
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
    
    public var loadState: LoadableState {
        state
    }
}

internal extension RefreshableWrapper where Value: IRecoilValue {
    var wrappedValue: Value.WrappedValue {
        value.wrappedValue
    }
}
