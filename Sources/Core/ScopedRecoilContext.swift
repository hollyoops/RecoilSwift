import Combine

/// Represents a scoped context for Recoil values, allowing binding and updates.
public class ScopedRecoilContext {
    private weak var store: Store?
    private let subscriptions: ScopedSubscriptions
    private let caches: ScopedNodeCaches
    private let viewRefresher: ViewRefreshable
    private let onValueChange: (((String, Any)) -> Void)?
 
    init(store: Store,
         subscriptions: ScopedSubscriptions,
         caches: ScopedNodeCaches,
         refresher: ViewRefreshable,
         onValueChange: (((String, Any)) -> Void)? = nil) {
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
        return nodeAccessor.get(valueNode)
    }
    
    public func useRecoilValue<Value: RecoilAsyncNode>(_ valueNode: Value) -> Value.T? {
        useRecoilValueLoadable(valueNode).data
    }
    
    public func useRecoilState<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> BindableValue<Value.T> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  self.nodeAccessor.get(stateNode)
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
                  self.nodeAccessor.get(stateNode)
              },
              set: { newState in
                  guard let newState else { return }
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
    
    public func useRecoilCallback<T>(_ fn: @escaping Callback<T>) -> T {
        let context = RecoilCallbackContext(
            get: nodeAccessor.getter(),
            set: nodeAccessor.setter(),
            store: subscriptions.store
        )
        return fn(context)
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
