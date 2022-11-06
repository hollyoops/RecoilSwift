import Foundation

protocol Store: AnyObject {
    func subscribe(for nodeKey: String, subscriber: Subscriber) -> Subscription
}

internal final class RecoilStore: Store {
    private var states: [String: any RecoilLoadable] = [:]
    private var subscriberMap: [String: Set<KeyedSubscriber>] = [:]
    private let graph = Graph()
    private let checker = DFSCircularChecker()
    static let shared = RecoilStore()
    
    func safeGetLoadable<T: RecoilValue>(for value: T) -> any RecoilLoadable {
        getLoadable(for: value.key) ?? register(value: value)
    }
    
    func getLoadable(for key: String) -> (any RecoilLoadable)? {
        states[key]
    }
    
    func getData<T>(for key: String, dataType: T.Type) -> T? {
        let load = getLoadable(for: key)
        return load?.data as? T
    }
    
    func getLoadingStatus(for key: String) -> Bool {
        guard let loadbox = getLoadable(for: key) else {
            return false
        }
        
        if loadbox.status == .loading {
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
            guard let loadbox = getLoadable(for: key) else {
                return
            }
            
            if let e = loadbox.error {
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
    
    func update<Recoil: RecoilValue>(recoilValue: Recoil, newValue: Recoil.T?) {
        guard let loadBox = getLoadbox(for: recoilValue) else {
            debugPrint("covert to loadbox failed, only loadbox supported for Now")
            return
        }
        loadBox.data = newValue
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
    private func register<T: RecoilValue>(value: T) -> any RecoilLoadable {
        //        check(value: value)
        let key = value.key
        let box = makeLoadBox(from: value)
        states[key] = box
        return box
    }
    
    private func makeLoadBox<T: RecoilValue>(from value: T) -> any RecoilLoadable {
        let loadable = LoadBox<T.T>(anyGetBody: value.get)
        
        _ = loadable.observe { [weak self] in
            self?.nodeValueChanged(key: value.key)
        }
        
        return loadable
    }
    
    private func notifyChanged(forKey key: String) {
        guard let subscribers = subscriberMap[key] else {
            return
        }
        subscribers.forEach { $0.valueDidChange() }
    }
    
    private func nodeValueChanged(key: String) {
        let downstreams = graph.getNode(for: key)?.downstream ?? []
        
        for item in downstreams {
            states[item]?.load()
        }
        
        notifyChanged(forKey: key)
    }
}

extension Dictionary {
    func has(_ key: Self.Key) -> Bool {
        self[key] != nil
    }
}

private extension RecoilStore {
    private func getLoadbox<T: RecoilValue>(for value: T) -> LoadBox<T.T>? {
        safeGetLoadable(for: value) as? LoadBox<T.T>
    }
}
