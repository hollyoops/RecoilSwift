public protocol RecoilNode<T> {
    associatedtype T: Equatable

    var key: NodeKey { get }
    
    func makeLoadable() -> BaseLoadable
}

extension RecoilNode {
    public var key: NodeKey {
        NodeKey(self)
    }
}

public protocol RecoilSyncNode: RecoilNode {
    func getValue(_ accessor: StateGetter) throws -> T
}

public extension RecoilSyncNode {
    func makeLoadable() -> BaseLoadable {
        return SyncLoadBox<T>(node: self)
    }
}

public protocol RecoilAsyncNode: RecoilNode {
    func getValue(_ accessor: StateGetter) async throws -> T
}

public extension RecoilAsyncNode {
    func makeLoadable() -> BaseLoadable {
        return AsyncLoadBox(node: self)
    }
}

public protocol Writeable {
    associatedtype T: Equatable
    
    func setValue(context: MutableContext, newValue: T)
}

public typealias RecoilMutableSyncNode = RecoilSyncNode & Writeable

public typealias RecoilMutableAsyncNode = RecoilAsyncNode & Writeable
