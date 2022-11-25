public protocol RecoilNode<T> {
    associatedtype T: Equatable
    
    var get: any Evaluator<T> { get }
    
    var key: String { get }
    
    func makeLoadable() -> BaseLoadable
}

public protocol RecoilSyncNode: RecoilNode { }

public extension RecoilSyncNode {
    func makeLoadable() -> BaseLoadable {
        return LoadBox<T>(anyGetBody: self.get)
    }
}

public protocol RecoilAsyncNode: RecoilNode { }
public extension RecoilAsyncNode {
    func makeLoadable() -> BaseLoadable {
        return LoadBox<T>(anyGetBody: self.get)
    }
}

public protocol Writeable {
    associatedtype T: Equatable
    
    func update(with value: T)
}

public typealias RecoilMutableSyncNode = RecoilSyncNode & Writeable

public typealias RecoilMutableAsyncNode = RecoilAsyncNode & Writeable

enum RecoilError: Error {
    case unknown
}
