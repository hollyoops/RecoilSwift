import SwiftUI

public struct RecoilRoot<Content: View>: View {
    private let content: Content
    private let enableShakeToDebug: Bool
    private let recoilStore: RecoilStore
    private let initFn: ((StateSetter) -> Void)?
    @State private var showDebugView = false
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
        if #available(iOS 14.0, *) {
            ZStack {
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
                    showDebugView = true
                }
            }
            .fullScreenCover(isPresented: $showDebugView) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Button("Dismiss") {
                            showDebugView = false
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    SnapshotView()
                }
            }
        } else {
            rootBody
        }
#else
        rootBody
#endif
    }

    var rootBody: some View {
        content
            .environment(\.store, recoilStore)
            .onAppear {
                if !isInited {
                    self.recoilStore.reset()
                    initFn?(NodeAccessor(store: self.recoilStore).setter(deps: nil))
                    isInited = true
                }
            }
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
