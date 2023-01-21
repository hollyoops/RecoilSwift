import SwiftUI

internal let globalStore = RecoilStore()

public struct RecoilRoot<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The content and behavior of the view.
    public var body: some View {
        content.environment(
            \.store,
             globalStore
        )
    }
}

internal extension EnvironmentValues {
    var store: Store {
        get { self[StoreEnvironmentKey.self] }
        set { self[StoreEnvironmentKey.self] = newValue }
    }
}

private struct StoreEnvironmentKey: EnvironmentKey {
    static var defaultValue: Store {
        globalStore
    }
}
