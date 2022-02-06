import SwiftUI
import RecoilSwift

public struct MainTabBar: HookView {
  public var hookBody: some View  {
    let selectedTab = useRecoilState(Home.selectedTabState)
    
    TabView(selection: selectedTab) {
      AllBooksView()
        .tag(HomeTab.list)
        .tabItem {
          Label("Books", systemImage: "books.vertical")
        }
      
      CartView()
        .tag(HomeTab.cart)
        .tabItem {
          Label("Cart", systemImage: "cart")
        }
      
      RemoteControllView()
        .tag(HomeTab.remote)
        .tabItem {
          Label("Remote", systemImage: "externaldrive.badge.icloud")
        }
    }
  }
}
