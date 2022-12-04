import Foundation

protocol Store: AnyObject {
    func subscribe(for nodeKey: String, subscriber: Subscriber) -> Subscription
    
    func safeGetLoadable<T: RecoilNode>(for node: T) -> BaseLoadable
    
    func getLoadable(for key: String) -> BaseLoadable?
    
    func getLoadingStatus(for key: String) -> Bool
    
    func getErrors(for key: String) -> [Error]
    
    func getData<T>(for key: String, dataType: T.Type) -> T?
    
    func makeConnect(key: String, upstream upKey: String)
}

internal final class RecoilStore: Store {
    private var states: [String: BaseLoadable] = [:]
    private var subscriberMap: [String: Set<KeyedSubscriber>] = [:]
    private let graph = Graph()
    private let checker = DFSCircularChecker()
    static let shared = RecoilStore()
    
    func safeGetLoadable<T: RecoilNode>(for node: T) -> BaseLoadable {
        getLoadable(for: node.key) ?? register(node)
    }
    
    func getLoadable(for key: String) -> BaseLoadable? {
        states[key]
    }
    
    func getData<T>(for key: String, dataType: T.Type) -> T? {
        let load = getLoadable(for: key)
        return load?.anyData as? T
    }
    
    func getLoadingStatus(for key: String) -> Bool {
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
    
    func getErrors(for key: String) -> [Error] {
        var errors = [Error]()
        
        func doGetError(key: String) {
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
    
    func makeConnect(key: String, upstream upKey: String) {
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
        
    func subscribe(for nodeKey: String, subscriber: Subscriber) -> Subscription {
        let keyedSubscriber = KeyedSubscriber(subscriber: subscriber)
        
        var subscribers = subscriberMap[nodeKey] ?? []
        subscribers.insert(keyedSubscriber)
        subscriberMap[nodeKey] = subscribers
    
        return Subscription { [weak self] in
            self?.subscriberMap[nodeKey]?.remove(keyedSubscriber)
            // TODO: try to release
        }
    }
    
    func reset() {
        states = [:]
        subscriberMap = [:]
        graph.reset()
    }
    
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
    
    private func notifyChanged<Node: RecoilNode>(node: Node, value: NodeStatus<Node.T>) {
        guard let subscribers = subscriberMap[node.key] else {
            return
        }
        subscribers.forEach { $0.valueDidChange(node: node, newValue: value) }
    }
    
    private func nodeValueChanged<Node: RecoilNode>(node: Node, value: NodeStatus<Node.T>) {
        let downstreams = graph.getNode(for: node.key)?.downstream ?? []
        
        for item in downstreams {
            states[item]?.load(Getter(store: self, context: node.key))
        }
        
        notifyChanged(node: node, value: value)
    }
}

extension Dictionary {
    func has(_ key: Self.Key) -> Bool {
        self[key] != nil
    }
}
