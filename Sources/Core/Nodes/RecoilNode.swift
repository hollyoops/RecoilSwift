public protocol RecoilNode<T> {
    associatedtype T: Equatable
    
    var get: any Evaluator<T> { get }
    
    var key: String { get }
}

public protocol RecoilSyncNode: RecoilNode { }

public protocol RecoilAsyncNode: RecoilNode { }

public protocol Writeable {
    associatedtype T: Equatable
    
    func update(with value: T)
}

public typealias RecoilMutableSyncNode = RecoilSyncNode & Writeable

public typealias RecoilMutableAsyncNode = RecoilAsyncNode & Writeable

enum RecoilError: Error {
    case unknown
}
