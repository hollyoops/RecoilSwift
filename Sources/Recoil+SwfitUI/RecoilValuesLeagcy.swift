#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS, introduced: 13, deprecated: 14, message: "Please use `RecoilValue` instead")
@propertyWrapper public struct RecoilValueLeagcy<T: IRecoilValue>: DynamicProperty {
    @ObservedObject private var state: RefreshableWrapper<T>
    
    public init(_ value: T) {
        _state = ObservedObject(wrappedValue: RefreshableWrapper(recoil: value))
    }
    
    public var wrappedValue: T.WrappedValue {
        state.wrappedValue
    }
    
    public var loadableState: LoadableState {
        state
    }
}

@available(iOS, introduced: 13, deprecated: 14, message: "Please use `RecoilState` instead")
@propertyWrapper public struct RecoilStateLeagcy<T: IRecoilState>: DynamicProperty {
    @ObservedObject private var state: RefreshableWrapper<T>

    public init(_ value: T) {
        _state = ObservedObject(wrappedValue: RefreshableWrapper(recoil: value))
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
    
    public var loadableState: LoadableState {
        state
    }
}
