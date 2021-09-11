import Foundation

internal final class Store {
    private var states: [String: Node] = [:]
    private var subscriberMap: [String: [Subscriber]] = [:]
    static let shared = Store()
    
    final class Node {
        let key: String
        private(set) var loadable: Loadable
        private(set) var upstream: Set<String> = []
        private(set) var downstream: Set<String> = []
        
        init(key: String, loadable: Loadable) {
            self.key = key
            self.loadable = loadable
        }
        
        func update(loadable: Loadable) {
            self.loadable = loadable
        }
        
        func add(upstream key: String) {
            upstream.insert(key)
        }
        
        func add(downstream key: String) {
            downstream.insert(key)
        }
    }
    
    @discardableResult
    func registerIfNotExist<T: RecoilValue>(for value: T) -> Node {
        states[value.key] ?? register(value: value)
    }
    
    func getNode(with key: String) -> Node? {
        states[key]
    }
    
    func check<T: RecoilValue>(value: T) {
        let key = value.key
        if states.keys.contains(key) {
            let message = "Cannot register a node with the same key: \(key)"
            dePrint(message)
            fatalError(message)
        }
    }
    
    func getLoadable<T: RecoilValue>(for value: T) -> Loadable {
        registerIfNotExist(for: value).loadable
    }
    
    func makeConnect(key: String, upstream upKey: String) {
        guard
            let node = getNode(with: key),
            let upstreamNode =  getNode(with: upKey)
        else {
            dePrint("Cannot make connect! \(key)")
#if DEBUG
            if states[key].isNone {
                dePrint("Node not exist: \(key)")
            }
            
            if states[upKey].isNone {
                dePrint("Node not exist: \(upKey)")
            }
#endif
            return
        }
        
        if node.upstream.contains(upKey) {
            return
        }
        
        // TODO: Check Circle Reference
        
        // Add
        node.add(upstream: upKey)
        upstreamNode.add(downstream: key)
    }
    
    func update<T: RecoilValue>(value: T)  {
        if let node = states[value.key] {
            let loadable = makeLoadBox(from: value)
            node.update(loadable: loadable)
            loadable.load()
        }  else {
            let node = register(value: value)
            node.loadable.load()
        }
    }
    
    func addObserver(forKey key: String, onChange: @escaping () -> Void) -> Subscriber {
        var subscribers = getSubscribers(forKey: key) ?? []
        
        let subscriber = Subscriber(onChange) { [weak self] sub in
            self?.removeObserver(forKey: key, subscriberID: sub.id)
        }
        
        subscribers.append(subscriber)
        subscriberMap[key] = subscribers
        
        return subscriber
    }
    
    private func removeObserver(forKey key: String, subscriberID: UUID) {
        guard var subscribers = getSubscribers(forKey: key) else {
            return
        }
        
        subscribers.removeAll { $0.id == subscriberID }
        if subscribers.isEmpty {
            subscriberMap.removeValue(forKey: key)
        } else {
            subscriberMap[key] = subscribers
        }
    }
    
    @discardableResult
    private func register<T: RecoilValue>(value: T) -> Node {
        check(value: value)
        
        let key = value.key
        let node = Node(key: key, loadable: makeLoadBox(from: value))
        states[key] = node
        return node
    }
    
    private func makeLoadBox<T: RecoilValue>(from value: T) -> LoadBox<T.LoadableType.Data, T.LoadableType.Failure> {
        let loadable = value.makeLoadable()
        guard let loadBox = value.castToLoadBox(from: loadable) else {
            fatalError("Make loadbox failed, only loadbox supported.")
        }
        
        _ = loadBox.observe { [weak self] in
            self?.nodeValueChanged(key: value.key)
        }
        
        return loadBox
    }
    
    private func getSubscribers(forKey key: String) -> [Subscriber]? {
        subscriberMap[key]
    }
    
    private func notifyChanged(forKey key: String) {
        guard let subscribers = getSubscribers(forKey: key) else {
            return
        }
        subscribers.forEach { $0() }
    }
    
    private func nodeValueChanged(key: String) {
        guard let node = getNode(with: key) else {
            return
        }
        
        for item in node.downstream {
            let itemNode = getNode(with: item)
            itemNode?.loadable.load()
        }
        
        notifyChanged(forKey: key)
    }
}

private extension RecoilValue {
    func castToLoadBox(from loadable: Loadable) -> LoadBox<LoadableType.Data, LoadableType.Failure>? {
        loadable as? LoadBox<LoadableType.Data, LoadableType.Failure>
    }
}