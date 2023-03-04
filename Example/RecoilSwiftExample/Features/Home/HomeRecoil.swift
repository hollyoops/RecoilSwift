import RecoilSwift

typealias HomeTab = Home.Tab

// MARK: - Atoms
struct Home {
  enum Tab {
    case list
    case remote
    case cart
  }
  
  static let selectedTabState = Atom<Tab>(.list)
    
  static let tabBarVisibleState = Atom<Bool>(true)
}

// MARK: - Actions
extension Home {
  static func selectTab(_ context: RecoilCallbackContext, tab: Tab) {
      context.accessor.set(selectedTabState, tab)
  }
}
