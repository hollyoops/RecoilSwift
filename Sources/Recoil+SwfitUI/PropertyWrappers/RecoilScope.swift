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

internal final class ScopedNodeCaches {
    private var nodeCaches: [NodeKey: Any] = [:]

    subscript(key: NodeKey) -> Any? {
        get { return nodeCaches[key] }
        set { nodeCaches[key] = newValue }
    }
    
    func peek<Node: RecoilNode>(for node: Node) -> NodeStatus<Node.T>? {
        nodeCaches[node.key] as? NodeStatus<Node.T>
    }
    
    func save<Node: RecoilNode>(_ node: Node, value: NodeStatus<Node.T>) {
        nodeCaches[node.key] = value
    }
    
    func clear() {
        nodeCaches = [:]
    }
}

internal final class ScopedSubscriptions {
    private var subscriptions: [NodeKey: Subscription] = [:]
    
    /// TODO: This is leagcy design to remove it later
    private var cancellables: Set<AnyCancellable> = []

    deinit {
        subscriptions.values.forEach { $0.unsubscribe() }
        subscriptions = [:]
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    subscript(key: NodeKey) -> Subscription? {
        get { return subscriptions[key] }
        set { subscriptions[key] = newValue }
    }
    
    func store(_ cancelable: AnyCancellable) {
        cancellables.insert(cancelable)
    }
}


@available(iOS 14.0, *)
@propertyWrapper
public struct RecoilScope: DynamicProperty {
    @Environment(\.store) private var store
    
    @StateObject private var viewRefersher: ViewRefresher = ViewRefresher()
    private let storeSubs = ScopedSubscriptions()
    private let caches = ScopedNodeCaches()

    public init() { }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            subscriptions: storeSubs,
                            caches: caches,
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
    private let storeSubs = ScopedSubscriptions()
    private let caches = ScopedNodeCaches()

    public init() { }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            subscriptions: storeSubs,
                            caches: caches,
                            refresher: viewRefersher)
    }

    internal func refresh() {
        viewRefersher.refresh()
    }
}
