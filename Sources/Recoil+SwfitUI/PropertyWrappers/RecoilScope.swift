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

internal final class ScopedStateCache: ObservableObject {
    private var subscriptions: [NodeKey: Subscription] = [:]
    private var caches: [NodeKey: Any] = [:]
    private(set) var snapshots: [Snapshot] = [] {
        didSet {
            onSnapshotChange?(snapshots)
        }
    }
    private(set) var maxSnapshot: Int = 1
    private var storeSub: Subscription?
    
    internal var onValueChange: (((NodeKey, Any)) -> Void)?
    internal var onSnapshotChange: (([Snapshot]) -> Void)?
    
    /// TODO: This is leagcy design to remove it later
    private var cancellables: Set<AnyCancellable> = []
    
    deinit {
        self.clear()
    }
    
    func store(_ cancelable: AnyCancellable) {
        cancellables.insert(cancelable)
    }
    
    func subscribe<Node: RecoilNode>(for node: Node, in store: Store) {
        if subscriptions.has(node.key) { return }
        let subscription = store.subscribe(for: node.key, subscriber: self)
        subscriptions[node.key] = subscription
    }
    
    func subscribe(store: Store) {
        guard storeSub == nil else { return }
        storeSub = store.subscribe(subscriber: self)
        snapshots = [store.getSnapshot()]
    }
    
    func peekCache<Node: RecoilNode>(for node: Node) -> NodeStatus<Node.T>? {
        caches[node.key] as? NodeStatus<Node.T>
    }
    
    func clear() {
        subscriptions.values.forEach { $0.unsubscribe() }
        storeSub?.unsubscribe()
        storeSub = nil
        caches = [:]
        subscriptions = [:]
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

extension ScopedStateCache: Subscriber {
    func snapshotChanged(snapshot: Snapshot) {
        snapshots = [snapshot]
    }
    
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
public struct RecoilScope: DynamicProperty {
    @Environment(\.store) private var store
    
    @StateObject private var viewRefersher: ViewRefresher = ViewRefresher()
    @StateObject private var cache = ScopedStateCache()

    public init() { }

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
    @ObservedObject private var cache = ScopedStateCache()
    
    public init() { }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store, cache: cache, refresher: viewRefersher)
    }

    internal func refresh() {
        viewRefersher.refresh()
    }
}
