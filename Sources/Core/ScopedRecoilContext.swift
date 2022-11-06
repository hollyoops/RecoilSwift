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
    
    public func useRecoilValue<Value: RecoilSyncValue>(_ valueNode: Value) -> Value.T {
        subscribeChange(for: valueNode)
        return Getter(valueNode.key)(valueNode)
    }
    
    public func useRecoilValue<Value: RecoilAsyncValue>(_ valueNode: Value) -> Value.T? {
        subscribeChange(for: valueNode)
        return Getter(valueNode.key)(valueNode)
    }
    
    public func useRecoilState<Value: RecoilState>(_ stateNode: Value) -> BindableValue<Value.T> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  Getter(stateNode.key)(stateNode)
              },
              set: { newState in
                  Setter(stateNode.key)(stateNode, newState)
              }
          )
    }
    
    public func useRecoilState<Value: RecoilAsyncState>(_ stateNode: Value) -> BindableValue<Value.T?> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  Getter(stateNode.key)(stateNode)
              },
              set: { newState in
                  guard let newState else { return }
                  Setter(stateNode.key)(stateNode, newState)
              }
          )
    }
    
    private func subscribeChange<Value: RecoilValue>(for node: Value) {
        guard let store else { return }
        let sub = store.subscribe(for: node.key, subscriber: self)
        subscriptions[node.key] = sub
    }

    func refresh() {
        viewRefresher.refresh()
    }
}

extension ScopedRecoilContext: Subscriber {
    func valueDidChange() {
        // TODO: improve performance
        // 1. if we can passback the changed value from.
        // 2. We can have cache. only refresh when value is change
        refresh()
    }
}
