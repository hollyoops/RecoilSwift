import SwiftUI

public struct RecoilRoot<Content: View>: View {
    private let content: Content
    private let enableShakeToDebug: Bool
    private let recoilStore: RecoilStore
    private let initFn: ((StateSetter) -> Void)?
    @State private var isShaken = false
    @State private var isInited = false
    
    public init(
        shakeToDebug: Bool = false,
        isSingleStore: Bool = true,
        initializeState: ((StateSetter) -> Void)? = nil,
        @ViewBuilder content: () -> Content) {
            self.recoilStore = isSingleStore ? globalStore : RecoilStore()
            self.content = content()
            self.enableShakeToDebug = shakeToDebug
            self.initFn = initializeState
        }
    
    /// The content and behavior of the view.
    public var body: some View {
#if canImport(UIKit)
        ZStack {
            // Your view content here
            content.environment(\.store, recoilStore)
        }
        .onAppear {
            if !isInited {
                initFn?(NodeAccessor(store: self.recoilStore).setter(deps: nil))
                isInited = true
            }
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
        content
            .environment(\.store, recoilStore)
            .onAppear {
                if !isInited {
                    self.recoilStore.reset()
                    initFn?(NodeAccessor(store: self.recoilStore).setter(deps: nil))
                    isInited = true
                }
            }
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
