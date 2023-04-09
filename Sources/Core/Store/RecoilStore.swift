import Foundation

protocol Store: AnyObject {
    func subscribe(for nodeKey: NodeKey, subscriber: Subscriber) -> Subscription
    
    func subscribe(subscriber: Subscriber) -> Subscription
    
    func safeGetLoadable<T: RecoilNode>(for node: T) -> BaseLoadable
    
    func getLoadable(for key: NodeKey) -> BaseLoadable?
    
    func getSnapshot() -> Snapshot
    
    func getLoadingStatus(for key: NodeKey) -> Bool
    
    func getErrors(for key: NodeKey) -> [Error]
    
    func addNodeRelation(downstream: NodeKey, upstream upKey: NodeKey)
}

internal final class RecoilStore: Store {
    internal let graph = Graph()
    private(set) var states: [NodeKey: BaseLoadable] = [:]
    private(set) var subscriberMap: [NodeKey: Set<KeyedSubscriber>] = [:]
    private(set) var storeSubscribers: Set<KeyedSubscriber> = []
    
    private let queue = DispatchQueue(label: "com.hollyoops.RecoilStore")
    private let queueValue = UUID()
    private let queueKey = DispatchSpecificKey<UUID>()
    
    init() {
        queue.setSpecific(key: queueKey, value: queueValue)
    }
    
    func safeGetLoadable<T: RecoilNode>(for node: T) -> BaseLoadable {
        executeOnQueue {
            return getLoadable(for: node.key) ?? register(node)
        }
    }
    
    func getLoadable(for key: NodeKey) -> BaseLoadable? {
        executeOnQueue {
            states[key]
        }
    }
    
    func getSnapshot() -> Snapshot {
        Snapshot(graph: graph)
    }
    
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
    
    func addNodeRelation(downstream: NodeKey, upstream: NodeKey) {
        executeOnQueue {
            guard states.has(downstream), states.has(upstream) else {
                dePrint("[Warning] Cannot make connect: \(downstream.name) -> \(upstream.name)")
#if DEBUG
                if !states.has(downstream) {
                    dePrint("[Warning] node not exist: \(downstream.name)")
                }
                
                if !states.has(upstream) {
                    dePrint("[Warning] Node not exist: \(upstream.name)")
                }
#endif
                return
            }
            
            guard !graph.isContainEdge(key: upstream, downstream: downstream) else {
                return
            }
            
            graph.addEdge(key: upstream, downstream: downstream)
        }
    }
    
    func subscribe(for nodeKey: NodeKey, subscriber: Subscriber) -> Subscription {
        return executeOnQueue {
            var subscribers = subscriberMap[nodeKey] ?? []
            let keyedSubscriber = KeyedSubscriber(subscriber: subscriber)
            
            if !subscribers.contains(keyedSubscriber) {
                subscribers.insert(keyedSubscriber)
                subscriberMap[nodeKey] = subscribers
            }
            
            return Subscription { [weak self] in
                self?.queue.sync {
                    guard let self = self else { return }
                    self.subscriberMap[nodeKey]?.remove(keyedSubscriber)
                    
                    if self.subscriberMap[nodeKey]?.isEmpty ?? false {
                        self.subscriberMap.removeValue(forKey: nodeKey)
                        self.releaseNode(nodeKey)
                    }
                }
            }
        }
    }
    
    func subscribe(subscriber: Subscriber) -> Subscription {
        let keyedSubscriber = KeyedSubscriber(subscriber: subscriber)
        
        return executeOnQueue {
            if !storeSubscribers.contains(keyedSubscriber) {
                storeSubscribers.insert(keyedSubscriber)
            }
            
            return Subscription { [weak self] in
                guard let self = self else { return }
                _ = self.executeOnQueue {
                    self.storeSubscribers.remove(keyedSubscriber)
                }
            }
        }
    }
    
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
    
    func reset() {
        queue.sync {
            self.states = [:]
            self.subscriberMap = [:]
            self.graph.reset()
        }
    }
    
    @discardableResult
    private func register<T: RecoilNode>(_ node: T) -> BaseLoadable {
        return executeOnQueue {
            let key = node.key
            let box = node.makeLoadable()
            _ = box.observeValueChange { [weak self] newValue in
                guard let val = newValue as? NodeStatus<T.T> else { return }
                self?.nodeValueChanged(node: node, value: val)
            }
            states[key] = box
            return box
        }
    }
    
    private func notifyNodeChanged<Node: RecoilNode>(node: Node, value: NodeStatus<Node.T>) {
        guard let subscribers = subscriberMap[node.key] else { return }
        
        subscribers.forEach {
            $0.valueDidChange(node: node, newValue: value)
        }
    }
    
    private func notifyStoreChanged() {
        let snapshot = getSnapshot()
        for subscriber in storeSubscribers {
            subscriber.storeChange(snapshot: snapshot)
        }
    }

    private func nodeValueChanged<Node: RecoilNode>(node: Node, value: NodeStatus<Node.T>) {
        executeOnQueue {
            let downstreams = graph.getNode(for: node.key)?.downstream ?? []
            
            for item in downstreams {
                NodeAccessor(store: self).refresh(for: item)
            }
            
            self.notifyNodeChanged(node: node, value: value)
            self.notifyStoreChanged()
        }
    }
}

extension Dictionary {
    func has(_ key: Self.Key) -> Bool {
        self[key] != nil
    }
}

extension RecoilStore {
    func executeOnQueue<T>(_ operation: () -> T) -> T {
        if DispatchQueue.getSpecific(key: queueKey) == queueValue {
            return operation()
        } else {
            return queue.sync {
                operation()
            }
        }
    }
}
