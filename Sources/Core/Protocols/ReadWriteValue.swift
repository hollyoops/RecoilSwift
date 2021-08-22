public protocol IIdentifiableValue {
    var key: String { get }
}

public protocol IRecoilValue: IObservableValue, IIdentifiableValue {
    associatedtype T: Equatable

    associatedtype DataType: Equatable
    
    func mount()
    
    var loadable: LoadableContainer<T> { get }
    
    var wrappedData: DataType { get }
}

public protocol IRecoilState: IRecoilValue {
    func update(_ newValue: DataType)
}
