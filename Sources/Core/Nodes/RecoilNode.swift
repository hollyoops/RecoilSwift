public protocol RecoilNode<T> {
    associatedtype T: Equatable

    var key: String { get }
    
    func makeLoadable() -> BaseLoadable
}

public protocol RecoilSyncNode: RecoilNode {
    var get: (Getter) throws -> T { get }
}

public extension RecoilSyncNode {
    func makeLoadable() -> BaseLoadable {
        return SyncLoadBox<T>(node: self)
    }
}

public protocol RecoilAsyncNode: RecoilNode {
    var get: (Getter) async throws -> T { get }
}

public extension RecoilAsyncNode {
    func makeLoadable() -> BaseLoadable {
        return AsyncLoadBox(node: self)
    }
}

public protocol Writeable {
    associatedtype T: Equatable
    
    func update(context: MutableContext, newValue: T)
}

public typealias RecoilMutableSyncNode = RecoilSyncNode & Writeable

public typealias RecoilMutableAsyncNode = RecoilAsyncNode & Writeable

enum RecoilError: Error {
    case unknown
}
