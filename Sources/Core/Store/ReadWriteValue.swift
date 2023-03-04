import Combine
public protocol StateGetter {
    func get<Node: RecoilSyncNode>(_ node: Node) throws -> Node.T
    
    func get<Node: RecoilAsyncNode>(_ node: Node) async throws -> Node.T
    
    func getOrNil<Node: RecoilNode>(_ node: Node) -> Node.T?
    
    func getUnsafe<Node: RecoilSyncNode>(_ node: Node) -> Node.T
}

public protocol StateSetter {
    func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void
}

public typealias StateAccessor = StateGetter & StateSetter

internal struct NodeAccessorWrapper: StateAccessor {
    private let nodeAccessor: NodeAccessor
    private let upstreamNodeKey: NodeKey?
    
    fileprivate init(nodeAccessor: NodeAccessor, upstreamKey: NodeKey?) {
        self.upstreamNodeKey = upstreamKey
        self.nodeAccessor = nodeAccessor
    }
    
    func getUnsafe<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        try! get(node)
    }
    
    public func get<Node: RecoilSyncNode>(_ node: Node) throws -> Node.T {
        buildRelation(node)
        return try nodeAccessor.get(node)
    }
    
    public func get<Node: RecoilAsyncNode>(_ node: Node) async throws -> Node.T {
        buildRelation(node)
        return try await nodeAccessor.get(node)
    }
    
    public func getOrNil<Node: RecoilNode>(_ node: Node) -> Node.T? {
        buildRelation(node)
        return nodeAccessor.safeGet(node)
    }
    
    public func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        nodeAccessor.set(node, newValue)
    }
    
    private func buildRelation<Node: RecoilNode>(_ node: Node) {
        guard let host = upstreamNodeKey else { return }
        
        let store = nodeAccessor.store
        _ = store.safeGetLoadable(for: node)
        store.makeConnect(key: host, upstream: node.key)
    }
}

public struct MutableContext {
    let accessor: StateAccessor
    let loadable: BaseLoadable
}

internal struct NodeAccessor {
    fileprivate let store: Store
    
    internal init(store: Store) {
        self.store = store
    }

    internal func get<Node: RecoilSyncNode>(_ node: Node) throws -> Node.T {
        guard let loadable = store.safeGetLoadable(for: node) as? SyncLoadBox<Node.T> else {
            // TODO: define a property error
            throw RecoilError.unknown
        }
        
        if let data = loadable.data {
            return data
        }
        
        if let error = loadable.error {
            throw error
        }
        
        do {
            return try loadable.compute(getter(upstreamKey: node.key))
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    internal func safeGet<Node: RecoilNode>(_ node: Node) -> Node.T? {
        let loadable = store.safeGetLoadable(for: node)
        
        if loadable.isInvalid {
            loadable.refresh(getter(upstreamKey: node.key))
        }
        
        return loadable.anyData as? Node.T
    }
    
    internal func get<Node: RecoilAsyncNode>(_ node: Node) async throws -> Node.T {
        guard let loadable = store.safeGetLoadable(for: node) as? AsyncLoadBox<Node.T> else {
            throw RecoilError.unknown
        }
        
        if let value = loadable.data {
            return value
        }
        
        if let error = loadable.error {
            throw error
        }
        
        if case let .loading(task) = loadable.status {
            return try await task.value
        }
        
        // The status invalid then should compute
        return try await loadable.compute(getter(upstreamKey: node.key)).value
    }
    
    internal func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        let ctx = MutableContext(
            accessor: accessor(upstreamKey: node.key),
            loadable: store.safeGetLoadable(for: node)
        )
        
        node.update(context: ctx, newValue: newValue)
    }
    
    internal func getter(upstreamKey: NodeKey? = nil) -> StateGetter {
        accessor(upstreamKey: upstreamKey)
    }

    internal func setter(upstreamKey: NodeKey? = nil) -> StateSetter {
        accessor(upstreamKey: upstreamKey)
    }
    
    internal func accessor(upstreamKey: NodeKey? = nil) -> StateAccessor {
        NodeAccessorWrapper(nodeAccessor: self, upstreamKey: upstreamKey)
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
