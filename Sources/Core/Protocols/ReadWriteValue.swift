public protocol IIdentifiableValue {
    var key: String { get }
}

public protocol IRecoilValue: IObservableValue, IIdentifiableValue {
    associatedtype T: Equatable

    associatedtype WrappedValue: Equatable
    
    func initNode()
    
    var loadable: LoadableContainer<T> { get }
    
    var wrappedValue: WrappedValue  { get }
}

public protocol IRecoilState: IRecoilValue {
    func update(_ newValue: WrappedValue)
}
