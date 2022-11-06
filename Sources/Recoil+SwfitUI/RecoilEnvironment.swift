import SwiftUI

internal extension EnvironmentValues {
    var store: Store {
        get { self[StoreEnvironmentKey.self] }
        set { self[StoreEnvironmentKey.self] = newValue }
    }
}

private struct StoreEnvironmentKey: EnvironmentKey {
    static var defaultValue: Store {
        RecoilStore.shared
    }
}
