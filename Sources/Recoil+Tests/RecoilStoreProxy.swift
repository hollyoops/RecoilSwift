import Foundation

class RecoilStoreProxy: Store {
    typealias AnyGet = () throws -> Any
    
    let store: RecoilStore
    private var stubValues: [NodeKey: AnyGet] = [:]
    
    init(store: RecoilStore) {
        self.store = store
    }

    func stub<Node: RecoilNode>(for node: Node, with value: Node.T) {
        stubValues[node.key] = {
            return value
        }
    }
    
    func stub<Node: RecoilNode>(for node: Node, with error: Error) {
        stubValues[node.key] = {
            throw error
        }
    }
    
    func stub<Node: RecoilNode>(_ node: Node, get: @escaping () throws -> Node.T) {
        stubValues[node.key] = get
    }
    
    func purge() {
        stubValues = [:]
        store.purge()
    }
}

public enum RecoilTestError: Error {
    case invalidState
}

extension RecoilStoreProxy {
    private func createStubNode<Node: RecoilNode>(for node: Node) -> (any RecoilNode)? {
        guard let stubValue = stubValues[node.key] else { return nil }
        
        let fn: () throws -> Node.T = {
            let value = try stubValue()
            guard let state = value as? Node.T else {
                throw RecoilTestError.invalidState
            }
            return state
        }
        
        if node is (any SyncAtomNode) {
            return Atom(key: node.key, get: { try fn() })
        }
        
        if node is (any AsyncAtomNode) {
            return AsyncAtom(key: node.key, get: { try fn()  })
        }
        
        if node is (any SyncSelectorNode) {
            return RecoilSwift.Selector(key: node.key, body: { _ in try fn() })
        }
        
        if node is (any AsyncSelectorNode) {
            return AsyncSelector(key: node.key, get: { _ in try fn() })
        }
        
        return nil
    }
    
    func safeGetLoadable<Node: RecoilNode>(for node: Node) -> BaseLoadable {
        if let stubNode = createStubNode(for: node) {
            return store.safeGetLoadable(for: stubNode)
        }
        
        return store.safeGetLoadable(for: node)
    }
    
    func getLoadable(for key: NodeKey) -> BaseLoadable? {
        return store.getLoadable(for: key)
    }
    
    func subscribe(for nodeKey: NodeKey, subscriber: Subscriber) -> Subscription {
        return store.subscribe(for: nodeKey, subscriber: subscriber)
    }
    
    func subscribe(subscriber: Subscriber) -> Subscription {
        return store.subscribe(subscriber: subscriber)
    }
    
    func getSnapshot() -> Snapshot {
        return store.getSnapshot()
    }
    
    func getLoadingStatus(for key: NodeKey) -> Bool {
        return store.getLoadingStatus(for: key)
    }
    
    func getErrors(for key: NodeKey) -> [Error] {
        return store.getErrors(for: key)
    }
    
    func addNodeRelation(downstream: NodeKey, upstream upKey: NodeKey) {
        store.addNodeRelation(downstream: downstream, upstream: upKey)
    }
}
