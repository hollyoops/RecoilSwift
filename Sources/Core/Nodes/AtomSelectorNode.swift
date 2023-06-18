public protocol SyncAtomNode: RecoilSyncNode, Writeable {
    func defaultValue() -> T
}

extension SyncAtomNode {
    public func getValue(_ accessor: StateGetter) throws -> T {
        defaultValue()
    }
}

public protocol AsyncAtomNode: RecoilAsyncNode {
    func defaultValue() async throws -> T
}

extension AsyncAtomNode {
    public func getValue(_ accessor: StateGetter) async throws -> T {
        try await defaultValue()
    }
}

public protocol SyncSelectorNode: RecoilSyncNode { }

public protocol AsyncSelectorNode: RecoilAsyncNode { }


extension SyncAtomNode where Self: Writeable {
    public func setValue(context: MutableContext, newValue: T) {
        guard let loadbox = context.loadable as? SyncLoadBox<T> else {
            return
        }
        
        loadbox.status = .solved(newValue)
    }
}

extension AsyncAtomNode where Self: Writeable {
    public func setValue(context: MutableContext, newValue: T) {
        guard let loadbox = context.loadable as? AsyncLoadBox<T> else {
            return
        }
        
        loadbox.status = .solved(newValue)
    }
}
