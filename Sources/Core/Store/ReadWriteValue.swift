public struct Getter {
    private let nodeAccessor: NodeAccessor
    private let upstreamNodeKey: NodeKey?

    fileprivate init(nodeAccessor: NodeAccessor, upstreamKey: NodeKey?) {
        self.upstreamNodeKey = upstreamKey
        self.nodeAccessor = nodeAccessor
    }
    
    public func callAsFunction<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        if let host = upstreamNodeKey {
            _ = nodeAccessor.store.safeGetLoadable(for: node)
            nodeAccessor.store.makeConnect(key: host, upstream: node.key)
        }
        
        return nodeAccessor.get(node)
    }
    
    public func callAsFunction<Node: RecoilAsyncNode>(_ node: Node) -> Node.T? {
        if let host = upstreamNodeKey {
            _ = nodeAccessor.store.safeGetLoadable(for: node)
            nodeAccessor.store.makeConnect(key: host, upstream: node.key)
        }
        
        return nodeAccessor.get(node)
    }
}

public struct Setter {
    private let nodeAccessor: NodeAccessor
    private let upstreamNodeKey: NodeKey?
    
    fileprivate init(nodeAccessor: NodeAccessor, upstreamKey: NodeKey? = nil) {
        self.upstreamNodeKey = upstreamKey
        self.nodeAccessor = nodeAccessor
    }
    
    public func callAsFunction<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        nodeAccessor.set(node, newValue)
    }
}

public struct MutableContext {
    let get: Getter
    let set: Setter
    let loadable: BaseLoadable
}

internal struct NodeAccessor {
    fileprivate let store: Store
    
    internal init(store: Store) {
        self.store = store
    }

    internal func get<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        guard let loadable = store.safeGetLoadable(for: node) as? SyncLoadBox<Node.T> else {
            fatalError(RecoilError.unknown.localizedDescription)
        }
        
        if let data = loadable.data {
            return data
        }
        
        if let error = loadable.error {
            fatalError(error.localizedDescription)
        }
        
        do {
            return try loadable.compute(getter(upstreamKey: node.key))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    internal func get<Node: RecoilAsyncNode>(_ node: Node) -> Node.T? {
        let loadable = store.safeGetLoadable(for: node)
        
        if loadable.isInvalid {
            loadable.refresh(getter(upstreamKey: node.key))
        }
        
        return loadable.anyData as? Node.T
    }
    
    internal func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        let ctx = MutableContext(
            get: getter(upstreamKey: node.key),
            set: setter(upstreamKey: node.key),
            loadable: store.safeGetLoadable(for: node)
        )
        
        node.update(context: ctx, newValue: newValue)
    }
    
    internal func getter(upstreamKey: NodeKey? = nil) -> Getter {
        Getter(nodeAccessor: self, upstreamKey: upstreamKey)
    }

    internal func setter(upstreamKey: NodeKey? = nil) -> Setter {
        Setter(nodeAccessor: self, upstreamKey: upstreamKey)
    }
    
    internal func loadNodeIfNeeded<T: RecoilNode>(_ node: T) {
        let loadable = store.safeGetLoadable(for: node)
        if loadable.isInvalid {
            loadable.refresh(getter(upstreamKey: node.key))
        }
    }
    
    internal func refresh<T: RecoilNode>(_ node: T) {
        let loadable = store.safeGetLoadable(for: node)
        loadable.refresh(getter(upstreamKey: node.key))
    }
    
    internal func refresh(for key: NodeKey) {
        store.getLoadable(for: key)?.refresh(getter(upstreamKey: key))
    }
}
