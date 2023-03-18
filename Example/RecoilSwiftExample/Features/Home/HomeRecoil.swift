import RecoilSwift

typealias HomeTab = Home.Tab

// MARK: - Atoms
struct Home {
    enum Tab {
        case list
        case remote
        case cart
    }
    
    static var selectedTabState: Atom<Tab> {
        atom(.list)
    }
    
    static var tabBarVisibleState: Atom<Bool> {
        atom(true)
    }
}

// MARK: - Actions
extension Home {
    static func selectTab(_ context: RecoilCallbackContext, tab: Tab) {
        context.accessor.set(selectedTabState, tab)
    }
}
