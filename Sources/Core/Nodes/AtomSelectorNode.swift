public protocol SyncAtomNode: RecoilSyncNode {
    func getValue() throws -> T
}

extension SyncAtomNode {
    public func getValue(_ accessor: StateGetter) throws -> T {
        try getValue()
    }
}

public protocol AsyncAtomNode: RecoilAsyncNode {
    func getValue() async throws -> T
}

extension AsyncAtomNode {
    public func getValue(_ accessor: StateGetter) async throws -> T {
        try await getValue()
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
