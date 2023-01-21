import Foundation

protocol Store: AnyObject {
    func subscribe(for nodeKey: NodeKey, subscriber: Subscriber) -> Subscription
    
    func safeGetLoadable<T: RecoilNode>(for node: T) -> BaseLoadable
    
    func getLoadable(for key: NodeKey) -> BaseLoadable?
    
    func getLoadingStatus(for key: NodeKey) -> Bool
    
    func getErrors(for key: NodeKey) -> [Error]
    
    func getData<T>(for key: NodeKey, dataType: T.Type) -> T?
    
    func makeConnect(key: NodeKey, upstream upKey: NodeKey)
}

internal final class RecoilStore: Store {
    private var states: [NodeKey: BaseLoadable] = [:]
    private var subscriberMap: [NodeKey: Set<KeyedSubscriber>] = [:]
    private let graph = Graph()
    private let checker = DFSCircularChecker()
    
    @MainActor
    func safeGetLoadable<T: RecoilNode>(for node: T) -> BaseLoadable {
        getLoadable(for: node.key) ?? register(node)
    }
    
    @MainActor
    func getLoadable(for key: NodeKey) -> BaseLoadable? {
        states[key]
    }
    
    @MainActor
    func getData<T>(for key: NodeKey, dataType: T.Type) -> T? {
        let load = getLoadable(for: key)
        return load?.anyData as? T
    }
    
    @MainActor
    func getLoadingStatus(for key: NodeKey) -> Bool {
        guard let loadable = getLoadable(for: key) else {
            return false
        }
        
        if loadable.isLoading {
            return true
        }
        
        if let node = graph.getNode(for: key) {
            for key in node.upstream {
                if getLoadingStatus(for: key) {
                    return true
                }
            }
        }
        
        return false
    }
    
    @MainActor
    func getErrors(for key: NodeKey) -> [Error] {
        var errors = [Error]()
        
        func doGetError(key: NodeKey) {
            guard let loadable = getLoadable(for: key) else {
                return
            }
            
            if let e = loadable.error {
                errors.append(e)
            }
            
            if let node = graph.getNode(for: key) {
                for key in node.upstream {
                    doGetError(key: key)
                }
            }
        }
        
        doGetError(key: key)
        
        return errors
    }
    
    @MainActor
    func makeConnect(key: NodeKey, upstream upKey: NodeKey) {
        guard states.has(key), states.has(upKey) else {
            dePrint("Cannot make connect! \(key)")
#if DEBUG
            if !states.has(key) {
                dePrint("Node not exist: \(key)")
            }
            
            if !states.has(upKey) {
                dePrint("Node not exist: \(upKey)")
            }
#endif
            return
        }
        
        if graph.isContainEdge(key: upKey, downstream: key) {
            return
        }
        
        if checker.canAddEdge(graph: graph, forKey: upKey, downstream: key) {
            graph.addEdge(key: upKey, downstream: key)
        }
    }
    
    @MainActor
    func subscribe(for nodeKey: NodeKey, subscriber: Subscriber) -> Subscription {
        let keyedSubscriber = KeyedSubscriber(subscriber: subscriber)
        
        var subscribers = subscriberMap[nodeKey] ?? []
        subscribers.insert(keyedSubscriber)
        subscriberMap[nodeKey] = subscribers
        
        return Subscription { [weak self] in
            DispatchQueue.main.async {
                self?.subscriberMap[nodeKey]?.remove(keyedSubscriber)
                // TODO: try to release
                self?.releaseNode(nodeKey)
            }
        }
    }
    
    @MainActor
    private func releaseNode(_ nodeKey: NodeKey) {
        // check should remove or not
        let isNilOrEmpty = self.subscriberMap[nodeKey]?.isEmpty ?? true
        guard isNilOrEmpty else { return }
        
        let deps = self.graph.dependencies(key: nodeKey)
        
        self.graph.removeNode(key: nodeKey)
        self.states.removeValue(forKey: nodeKey)
        
        for dep in deps {
            releaseNode(dep)
        }
    }
    
    @MainActor
    func reset() {
        self.states = [:]
        self.subscriberMap = [:]
        self.graph.reset()
    }
    
    @MainActor
    @discardableResult
    private func register<T: RecoilNode>(_ node: T) -> BaseLoadable {
        let key = node.key
        let box = node.makeLoadable()
        _ = box.observeValueChange { [weak self] newValue in
            guard let val = newValue as? NodeStatus<T.T> else { return }
            self?.nodeValueChanged(node: node, value: val)
        }
        states[key] = box
        return box
    }
    
    @MainActor
    private func notifyChanged<Node: RecoilNode>(node: Node, value: NodeStatus<Node.T>) {
        guard let subscribers = subscriberMap[node.key] else {
            return
        }
        subscribers.forEach { $0.valueDidChange(node: node, newValue: value) }
    }
    
    @MainActor
    private func nodeValueChanged<Node: RecoilNode>(node: Node, value: NodeStatus<Node.T>) {
        let downstreams = graph.getNode(for: node.key)?.downstream ?? []
        
        for item in downstreams {
            NodeAccessor(store: self).refresh(for: item)
        }
        
        self.notifyChanged(node: node, value: value)
    }
}

extension Dictionary {
    func has(_ key: Self.Key) -> Bool {
        self[key] != nil
    }
}
