import SwiftUI

@available(iOS 14.0, *)
@propertyWrapper
public struct RecoilSnapshot: DynamicProperty {
    @Environment(\.store) private var store
    
    @StateObject private var viewRefersher: ViewRefresher = ViewRefresher()
    private let cache = ScopedStateCache()

    public init() { }

    public var wrappedValue: Snapshot {
        if cache.onSnapshotChange == nil {
            cache.onSnapshotChange = { _ in
                self.refresh()
            }
            cache.subscribe(store: store)
        }
        
        return cache.snapshots.first ?? store.getSnapshot()
    }
    
    internal func refresh() {
        viewRefersher.refresh()
    }
}

extension Snapshot: ObservableObject {}
