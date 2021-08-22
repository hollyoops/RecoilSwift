public protocol Getter {
    typealias SideEffectType = IIdentifiableValue & IObservableValue

    func callAsFunction<U: IRecoilValue>(_ recoilValue: U) -> U.DataType
}

public struct GetterFunction: Getter {
    var sideEffect: ((SideEffectType) -> Void)?

    public func callAsFunction<U: IRecoilValue>(_ recoilValue: U) -> U.DataType {
        sideEffect?(recoilValue)
        return recoilValue.wrappedData
    }
}

public protocol Setter {
    func callAsFunction<U: IRecoilState>(_ state: U, _ newValue: U.DataType) -> Void
}

extension Setter {
    public func callAsFunction<U: IRecoilState>(_ state: U, _ newValue: U.DataType) -> Void {
        state.update(newValue)
    }
}

public struct SetterFunction: Setter {}
