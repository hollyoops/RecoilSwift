public protocol Getter {
    typealias SideEffectType = IIdentifiableValue & IObservableValue

    func callAsFunction<U: IRecoilValue>(_ recoilValue: U) -> U.WrappedValue
}

public struct GetterFunction: Getter {
    var sideEffect: ((SideEffectType) -> Void)?

    public func callAsFunction<U: IRecoilValue>(_ recoilValue: U) -> U.WrappedValue {
        sideEffect?(recoilValue)
        return recoilValue.wrappedValue
    }
}

public protocol Setter {
    func callAsFunction<U: IRecoilState>(_ state: U, _ newValue: U.WrappedValue) -> Void
}

extension Setter {
    public func callAsFunction<U: IRecoilState>(_ state: U, _ newValue: U.WrappedValue) -> Void {
        state.update(newValue)
    }
}

public struct SetterFunction: Setter {}
