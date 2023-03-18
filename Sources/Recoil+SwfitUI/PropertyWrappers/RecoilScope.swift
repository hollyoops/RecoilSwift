import SwiftUI
import Combine

internal final class ViewRefresher: ObservableObject, ViewRefreshable {
    func refresh() {
        // fix the render warning while view update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

internal final class ScopedStateCache {
    private var subscriptions: [NodeKey: Subscription] = [:]
    private var caches: [NodeKey: Any] = [:]
    
    internal var onValueChange: (((NodeKey, Any)) -> Void)?
    
    /// TODO: This is leagcy design to remove it later
    private var cancellables: Set<AnyCancellable> = []
    
    deinit {
        subscriptions.values.forEach { $0.unsubscribe() }
        self.clear()
    }
    
    func store(_ cancelable: AnyCancellable) {
        cancellables.insert(cancelable)
    }
    
    func subscribe<Node: RecoilNode>(for node: Node, in store: Store) {
        let subscription = store.subscribe(for: node.key, subscriber: self)
        subscriptions[node.key] = subscription
    }
    
    private func peekCache<Node: RecoilNode>(for node: Node) -> NodeStatus<Node.T>? {
        caches[node.key] as? NodeStatus<Node.T>
    }
    
    func clear() {
        caches = [:]
        subscriptions = [:]
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

extension ScopedStateCache: Subscriber {
    func valueDidChange<Node: RecoilNode>(node: Node, newValue: NodeStatus<Node.T>) {
        if let value = peekCache(for: node), value == newValue {
            return
        }
        
        caches[node.key] = newValue
        onValueChange?((node.key, newValue))
    }
}

@available(iOS 14.0, *)
@propertyWrapper
public class RecoilScope: DynamicProperty {
    @Environment(\.store) private var store
    
    @StateObject private var viewRefersher: ViewRefresher = ViewRefresher()
    private let cache = ScopedStateCache()

    public init() {
        self.cache.onValueChange = { [weak self] _ in
            self?.refresh()
        }
    }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            cache: cache,
                            refresher: viewRefersher)
    }
    
    internal func refresh() {
        viewRefersher.refresh()
    }
}

@available(iOS, introduced: 13.0, deprecated: 14.0)
@propertyWrapper
public struct RecoilScopeLeagcy: DynamicProperty {
    @Environment(\.store) private var store
    @ObservedObject private var viewRefersher: ViewRefresher = ViewRefresher()
    private let cache = ScopedStateCache()
    
    public init() { }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store, cache: cache, refresher: viewRefersher)
    }

    internal func refresh() {
        viewRefersher.refresh()
    }
}
