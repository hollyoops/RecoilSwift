public struct Getter {
    private let contextKey: String?
    private let store: Store
    
    init(_ context: String? = nil, store: Store = RecoilStore.shared) {
        self.contextKey = context
        self.store = store
    }
    
    public func callAsFunction<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        let loadable = store.safeGetLoadable(for: node)
        
        if let host = contextKey {
            store.makeConnect(key: host, upstream: node.key)
        }
        
        if loadable.isInvalid {
            loadable.load()
        }
        
        guard let data = loadable.anyData as? Node.T else {
            let error = loadable.error ?? RecoilError.unknown
            fatalError(error.localizedDescription)
        }
        
        return data
    }
    
    public func callAsFunction<Node: RecoilAsyncNode>(_ node: Node) -> Node.T? {
        let loadable = store.safeGetLoadable(for: node)
        
        if let host = contextKey {
            store.makeConnect(key: host, upstream: node.key)
        }
        
        if loadable.isInvalid {
            loadable.load()
        }
        
        return loadable.anyData as? Node.T
    }
}

public struct Setter {
    private let contextKey: String?
    private let store: Store
    
    internal init(_ context: String? = nil, store: Store = RecoilStore.shared) {
        self.store = store
        self.contextKey = context
    }
    
    public func callAsFunction<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        let loadable = store.safeGetLoadable(for: node)
        
        let ctx = MutableContext(
            get: Getter(node.key, store: store),
            set: Setter(node.key, store: store),
            loadable: loadable
        )
        
        node.update(context: ctx, newValue: newValue)
    }
}

public struct MutableContext {
    let get: Getter
    let set: Setter
    let loadable: BaseLoadable
}
