import SwiftUI

internal final class ViewRefresher: ObservableObject, ViewRefreshable {
    func refresh() {
        // fix the render warning while view update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

internal final class ScopedSubscriptions {
    private var subscriptions: [String: Subscription] = [:]

    deinit {
        subscriptions.values.forEach { $0.unsubscribe() }
        subscriptions = [:]
    }

    subscript(key: String) -> Subscription? {
        get { return subscriptions[key] }
        set { subscriptions[key] = newValue }
    }
}


@available(iOS 14.0, *)
@propertyWrapper
public struct RecoilScope: DynamicProperty {
    @Environment(\.store) private var store
    
    @StateObject private var viewRefersher: ViewRefresher = ViewRefresher()
    private let storeSubs = ScopedSubscriptions()

    public init() { }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            subscriptions: storeSubs,
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

    public init() { }

    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            subscriptions: storeSubs,
                            refresher: viewRefersher)
    }

    internal func refresh() {
        viewRefersher.refresh()
    }
}
