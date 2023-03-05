import Combine

/// Represents a scoped context for Recoil values, allowing binding and updates.
public class ScopedRecoilContext {
    private weak var store: Store?
    private let subscriptions: ScopedSubscriptions
    private let caches: ScopedNodeCaches
    private let viewRefresher: ViewRefreshable
    private let onValueChange: (((NodeKey, Any)) -> Void)?
 
    init(store: Store,
         subscriptions: ScopedSubscriptions,
         caches: ScopedNodeCaches,
         refresher: ViewRefreshable,
         onValueChange: (((NodeKey, Any)) -> Void)? = nil) {
        self.viewRefresher = refresher
        self.store = store
        self.subscriptions = subscriptions
        self.caches = caches
        self.onValueChange = onValueChange
    }
    
    private var nodeAccessor: NodeAccessor {
        NodeAccessor(store: self.unsafeStore)
    }
    
    public func useRecoilValue<Value: RecoilSyncNode>(_ valueNode: Value) -> Value.T {
        subscribeChange(for: valueNode)
        do {
            return try nodeAccessor.get(valueNode, deps: [])
        } catch {
            // TODO:
            print(error)
            fatalError(error.localizedDescription)
        }
    }
    
    public func useRecoilValue<Value: RecoilAsyncNode>(_ valueNode: Value) -> Value.T? {
        useRecoilValueLoadable(valueNode).data
    }
    
    public func useRecoilState<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> BindableValue<Value.T> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  try! self.nodeAccessor.get(stateNode, deps: []) // TODO:
              },
              set: { newState in
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
    
    public func useRecoilState<Value: RecoilMutableAsyncNode>(_ stateNode: Value) -> BindableValue<Value.T?> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  self.nodeAccessor.getOrNil(stateNode, deps: [])
              },
              set: { newState in
                  guard let newState else { return }
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
    
    public func useRecoilCallback<T>(_ fn: @escaping Callback<T>) -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: subscriptions.store
        )
        return fn(context)
    }
    
    public func useRecoilCallback<T>(_ fn: @escaping AsyncCallback<T>) async throws -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: subscriptions.store
        )
        
        return try await fn(context)
    }
    
    public func useRecoilValueLoadable<Value: RecoilNode>(_ valueNode: Value) -> LoadableContent<Value.T> {
        subscribeChange(for: valueNode)
//        let loadble = store?.safeGetLoadable(for: valueNode)
//        if loadble == .invalid {
//            loadble.compute(/*excutatble_info*/)
//        }
        return LoadableContent(node: valueNode, store: unsafeStore)
    }
    
    private var unsafeStore: Store {
        guard let store else {
            fatalError("Should have store! pls make sure the add RecoilRoot in your root of view")
        }
        
        return store
    }
    
    private func subscribeChange<Value: RecoilNode>(for node: Value) {
        guard let store else { return }
        let sub = store.subscribe(for: node.key, subscriber: self)
        subscriptions[node.key] = sub
    }

    func refresh() {
        viewRefresher.refresh()
    }
}

extension ScopedRecoilContext: Subscriber {
    func valueDidChange<Node: RecoilNode>(node: Node, newValue: NodeStatus<Node.T>) {
        // Only refresh when value is change
        if let value = caches.peek(for: node),
           value == newValue {
            return
        }
        
        caches[node.key] = newValue
        onValueChange?((node.key, newValue))
        refresh()
    }
}
