/// Represents a scoped context for Recoil values, allowing binding and updates.
public class ScopedRecoilContext {
    internal let viewRefresher: ViewRefreshable
    private weak var store: Store?
    private let subscriptions: ScopedSubscriptions
    
    /// Initializes a new `ScopedRecoilContext`.
    ///
    /// - Parameters:
    ///   - store: An weak `Store` ref to use for Recoil state management.
    ///   - subscriptions: An container store all the Subscriptions for this scope
    ///   - refresher: An optional `ViewRefreshable` instance to handle view updates.
    internal init(store: Store,
                  subscriptions: ScopedSubscriptions,
                  refresher: ViewRefreshable) {
        self.viewRefresher = refresher
        self.subscriptions = subscriptions
        self.store = store
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
        // TODO: improve performance We can have cache. only refresh when value is change
        refresh()
    }
}
