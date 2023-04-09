import SwiftUI

internal let globalStore = RecoilStore()

public struct RecoilRoot<Content: View>: View {
    private let content: Content
    private let enableShakeToDebug: Bool
    @State private var isShaken = false
    
    public init(shakeToDebug: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.enableShakeToDebug = shakeToDebug
    }
    /// The content and behavior of the view.
    public var body: some View {
#if canImport(UIKit)
        ZStack {
            // Your view content here
            content.environment(
                \.store,
                 globalStore
            )
        }
        .onShake {
            if enableShakeToDebug {
                isShaken = true
            }
        }
        .sheet(isPresented: $isShaken) {
            if #available(iOS 14.0, *) {
                SnapshotView()
            } else {
                // Fallback on earlier versions
            }
        }
#else
        content.environment(
            \.store,
             globalStore
        )
#endif
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
