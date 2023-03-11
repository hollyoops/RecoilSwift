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
    private let needBuildDependencies: Bool
    private let deps: [NodeKey]
    
    fileprivate init(nodeAccessor: NodeAccessor, deps: [NodeKey], buildDependencies: Bool) {
        self.nodeAccessor = nodeAccessor
        self.needBuildDependencies = buildDependencies
        self.deps = deps
    }
    
    func getUnsafe<Node: RecoilSyncNode>(_ node: Node) -> Node.T {
        try! get(node)
    }
    
    public func get<Node: RecoilSyncNode>(_ node: Node) throws -> Node.T {
        try buildRelation(node)
        return try nodeAccessor.get(node, deps: deps)
    }
    
    public func get<Node: RecoilAsyncNode>(_ node: Node) async throws -> Node.T {
        try buildRelation(node)
        return try await nodeAccessor.get(node, deps: deps)
    }
    
    public func getOrNil<Node: RecoilNode>(_ node: Node) -> Node.T? {
        do {
            try buildRelation(node)
            return nodeAccessor.getOrNil(node, deps: deps)
        } catch {
            return nil
        }
    }
    
    public func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        nodeAccessor.set(node, newValue)
    }
    
    private func buildRelation<Node: RecoilNode>(_ node: Node) throws {
        guard needBuildDependencies, let nodeKey = deps.first else {
            return
        }
        
        guard !deps.contains(node.key) else {
            throw RecoilError.circular
        }
        
        let store = nodeAccessor.store
        _ = store.safeGetLoadable(for: node)
        store.addNodeRelation(downstream: nodeKey, upstream: node.key)
    }
}

public struct MutableContext {
    public let accessor: StateAccessor
    public let loadable: BaseLoadable
}

internal struct NodeAccessor {
    fileprivate let store: Store
    
    internal init(store: Store) {
        self.store = store
    }
    
    internal func get<Node: RecoilSyncNode>(_ node: Node, deps: [NodeKey]?) throws -> Node.T {
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
        
        let dependencies = deps.map { $0 + [node.key] }
        return try loadable.getValue(getter(deps: dependencies))
    }
    
    internal func getOrNil<Node: RecoilNode>(_ node: Node, deps: [NodeKey]?) -> Node.T? {
        let loadable = store.safeGetLoadable(for: node)
        
        if loadable.isInvalid {
            let dependencies = deps.map { $0 + [node.key] }
            loadable.refresh(getter(deps: dependencies))
        }
        
        return loadable.anyData as? Node.T
    }
    
    internal func get<Node: RecoilAsyncNode>(_ node: Node, deps: [NodeKey]?) async throws -> Node.T {
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
        let dependencies = deps.map { $0 + [node.key] }
        return try await loadable.getValue(getter(deps: dependencies)).value
    }
    
    internal func set<T: RecoilNode & Writeable>(_ node: T, _ newValue: T.T) -> Void {
        let ctx = MutableContext(
            accessor: accessor(deps: nil),
            loadable: store.safeGetLoadable(for: node)
        )
        
        node.setValue(context: ctx, newValue: newValue)
    }
    
    internal func getter(deps: [NodeKey]?) -> StateGetter {
        accessor(deps: deps)
    }

    internal func setter(deps: [NodeKey]?) -> StateSetter {
        accessor(deps: deps)
    }
    
    internal func accessor(deps: [NodeKey]?) -> StateAccessor {
        let shouldbuildDependencies = deps.isSome
        return NodeAccessorWrapper(nodeAccessor: self,
                            deps: deps ?? [],
                            buildDependencies: shouldbuildDependencies)
    }
                                
    internal func loadNodeIfNeeded<T: RecoilNode>(_ node: T) {
        let loadable = store.safeGetLoadable(for: node)
        if loadable.isInvalid {
            loadable.refresh(getter(deps: [node.key]))
        }
    }
    
    internal func refresh<T: RecoilNode>(_ node: T) {
        let loadable = store.safeGetLoadable(for: node)
        loadable.refresh(getter(deps: [node.key]))
    }
    
    internal func refresh(for key: NodeKey) {
        store.getLoadable(for: key)?.refresh(getter(deps: [key]))
    }
}
