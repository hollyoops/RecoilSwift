public protocol SyncAtomNode: RecoilSyncNode {
    func compute() throws -> T
}

extension SyncAtomNode {
    public func compute(_ accessor: StateGetter) throws -> T {
        try compute()
    }
}

public protocol AsyncAtomNode: RecoilAsyncNode {
    func compute() async throws -> T
}

extension AsyncAtomNode {
    public func compute(_ accessor: StateGetter) async throws -> T {
        try await compute()
    }
}

public protocol SyncSelectorNode: RecoilSyncNode { }

public protocol AsyncSelectorNode: RecoilAsyncNode { }


extension SyncAtomNode where Self: Writeable {
    public func update(context: MutableContext, newValue: T) {
        guard let loadbox = context.loadable as? SyncLoadBox<T> else {
            return
        }
        
        loadbox.status = .solved(newValue)
    }
}

extension AsyncAtomNode where Self: Writeable {
    public func update(context: MutableContext, newValue: T) {
        guard let loadbox = context.loadable as? AsyncLoadBox<T> else {
            return
        }
        
        loadbox.status = .solved(newValue)
    }
}
