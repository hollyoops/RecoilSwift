public struct Getter {
    private let nodeAccessor: NodeAccessor
    private let contextKey: String?

    fileprivate init( nodeAccessor: NodeAccessor, contextKey: String? = nil) {
        self.contextKey = contextKey
        self.nodeAccessor = nodeAccessor
    }
    
    public func callAsFunction<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        if let host = contextKey {
            _ = nodeAccessor.store.safeGetLoadable(for: node)
            nodeAccessor.store.makeConnect(key: host, upstream: node.key)
        }
        
        return nodeAccessor.get(node)
    }
    
    public func callAsFunction<Node: RecoilAsyncNode>(_ node: Node) -> Node.T? {
        if let host = contextKey {
            _ = nodeAccessor.store.safeGetLoadable(for: node)
            nodeAccessor.store.makeConnect(key: host, upstream: node.key)
        }
        
        return nodeAccessor.get(node)
    }
}

public struct Setter {
    private let nodeAccessor: NodeAccessor
    private let contextKey: String?
    
    fileprivate init( nodeAccessor: NodeAccessor, contextKey: String? = nil) {
        self.contextKey = contextKey
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

    internal func getter(contextKey: String? = nil) -> Getter {
        Getter(nodeAccessor: self, contextKey: contextKey)
    }

    internal func setter(contextKey: String? = nil) -> Setter {
        Setter(nodeAccessor: self, contextKey: contextKey)
    }
    
    public func get<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        let loadable = store.safeGetLoadable(for: node)
        
        if loadable.isInvalid {
            loadable.load(getter(contextKey: node.key))
        }
        
        guard let data = loadable.anyData as? Node.T else {
            let error = loadable.error ?? RecoilError.unknown
            fatalError(error.localizedDescription)
        }
        
        return data
    }
    
    public func get<Node: RecoilAsyncNode>(_ node: Node) -> Node.T? {
        let loadable = store.safeGetLoadable(for: node)
        
        if loadable.isInvalid {
            loadable.load(getter(contextKey: node.key))
        }
        
        return loadable.anyData as? Node.T
    }
    
    public func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        let ctx = MutableContext(
            get: getter(contextKey: node.key),
            set: setter(contextKey: node.key),
            loadable: store.safeGetLoadable(for: node)
        )
        
        node.update(context: ctx, newValue: newValue)
    }
    
    internal func loadNodeIfNeeded<T: RecoilNode>(_ node: T) {
        let loadable = store.safeGetLoadable(for: node)
        if loadable.isInvalid {
            loadable.load(getter(contextKey: node.key))
        }
    }
    
    internal func load<T: RecoilNode>(_ node: T) {
        let loadable = store.safeGetLoadable(for: node)
        loadable.load(getter(contextKey: node.key))
    }
}
