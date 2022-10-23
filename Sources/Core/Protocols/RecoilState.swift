public protocol RecoilWriteable {
    associatedtype DataType: Equatable
    
    func update(with value: DataType)
}

public typealias RecoilState = RecoilValue & RecoilWriteable
