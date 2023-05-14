import SwiftUI

@available(iOS 14.0, *)
public struct RecoilRoot<Content: View>: View {
    private let content: Content
    private let enableShakeToDebug: Bool
    private let recoilStore: RecoilStore
    private let initFn: ((StateSetter) -> Void)?
    private let useGlobalStore: Bool
    @State private var showDebugView = false
    @State private var isInited = false
    @StateObject private var disposer: RootDisposer = RootDisposer()
    
    public init(
        shakeToDebug: Bool = false,
        isSingleStore: Bool = true,
        initializeState: ((StateSetter) -> Void)? = nil,
        @ViewBuilder content: () -> Content) {
            self.recoilStore = isSingleStore ? globalStore : RecoilStore()
            self.content = content()
            self.enableShakeToDebug = shakeToDebug
            self.initFn = initializeState
            self.useGlobalStore = isSingleStore
        }
    
    /// The content and behavior of the view.
    public var body: some View {
#if canImport(UIKit)
        ZStack {
            contentView
        }
        .onAppear {
            initRoot()
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
#else
        contentView
            .onAppear { initRoot() }
#endif
    }
    
    func initRoot() {
        disposer.useGlobalStore = useGlobalStore
        if !isInited {
            initFn?(NodeAccessor(store: self.recoilStore).setter(deps: nil))
            isInited = true
        }
    }

    @ViewBuilder var contentView: some View {
        if isInited {
            content.environment(\.store, recoilStore)
        } else {
            EmptyView()
        }
    }
}

@available(iOS, deprecated: 14.0, message: "use `RecoilRoot` instead")
public struct RecoilRootLeagcy<Content: View>: View {
    private let content: Content
    private let recoilStore: RecoilStore
    private let initFn: ((StateSetter) -> Void)?
    @State private var isInited = false
    
    public init(
        initializeState: ((StateSetter) -> Void)? = nil,
        @ViewBuilder content: () -> Content) {
            self.recoilStore = globalStore
            self.content = content()
            self.initFn = initializeState
        }
    
    public var body: some View {
        contentView
            .onAppear { initRoot() }
    }

    @ViewBuilder var contentView: some View {
        if isInited {
            content.environment(\.store, recoilStore)
        } else {
            EmptyView()
        }
    }
    
    func initRoot() {
        if !isInited {
            globalStore.reset()
            initFn?(NodeAccessor(store: self.recoilStore).setter(deps: nil))
            isInited = true
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

private class RootDisposer: ObservableObject {
    var useGlobalStore: Bool = true
    deinit {
        if useGlobalStore {
            globalStore.reset()
        }
    }
}
