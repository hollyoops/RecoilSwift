/// A class that represents the subscription returned by the store when subscribing.
protocol Subscriber: AnyObject {
    func valueDidChange<Node: RecoilNode>(node: Node, newValue: NodeStatus<Node.T>)
    
    func storeChange(snapshot: Snapshot)
}

extension Subscriber {
    func valueDidChange<Node: RecoilNode>(node: Node, newValue: NodeStatus<Node.T>) { }
    
    func storeChange(snapshot: Snapshot) { }
}

class KeyedSubscriber: Hashable {
    let id: ObjectIdentifier
    private let subscriber: Subscriber
    
    init(subscriber: Subscriber) {
        self.id = ObjectIdentifier(subscriber)
        self.subscriber = subscriber
    }

    static func == (lhs: KeyedSubscriber, rhs: KeyedSubscriber) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension KeyedSubscriber: Subscriber {
    func valueDidChange<Node: RecoilNode>(node: Node, newValue: NodeStatus<Node.T>) {
        subscriber.valueDidChange(node: node, newValue: newValue)
    }
    
    func storeChange(snapshot: Snapshot) {
        subscriber.storeChange(snapshot: snapshot)
    }
}

public struct Subscription {
    private let unsubscribeFn: () -> Void

    /// Initialize a new RecoilStoreSubscription.
    /// - Parameter unsubscribe: The closure that will be executed when unsubscribing.
    init(unsubscribe: @escaping () -> Void) {
        self.unsubscribeFn = unsubscribe
    }

    /// Unsubscribe from the store.
    func unsubscribe() {
        self.unsubscribeFn()
    }
}
