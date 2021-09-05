public protocol RecoilIdentifiable {
    var key: String { get }
}

public protocol RecoilReadable: RecoilIdentifiable {
    associatedtype DataType: Equatable
    
    associatedtype LoadableType: RecoilLoadable
    
    func makeLoadable() -> LoadableType
    
    func data(from: Loadable) -> DataType
}

public protocol RecoilWriteable {
    associatedtype DataType: Equatable
    
    func update(with value: DataType)
}

public typealias RecoilState = RecoilValue & RecoilWriteable

public typealias RecoilValue = RecoilReadable
