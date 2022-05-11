import SwiftUI
import RecoilSwift

public struct MainTabView: HookView {
    public var hookBody: some View  {
        let selectedTab = useRecoilState(Home.selectedTabState)
        let isTabBarVisible = useRecoilValue(Home.tabBarVisibleState)
        let badgeText = useRecoilValue(Cart.cartItemBadgeState)
        
        ZStack(alignment: .bottom) {
            TabView(selection: selectedTab) {
                AllBooksView()
                    .tag(HomeTab.list)
          
                CartView()
                    .tag(HomeTab.cart)
            
                RemoteControllView()
                    .tag(HomeTab.remote)
            }
           
            if isTabBarVisible {
                TabBar {
                    TabBarItem(selectedTab: selectedTab, label: "Books", systemImage: "books.vertical")
                        .tag(.list)
                    
                    TabBarItem(selectedTab: selectedTab, label: "Cart", systemImage: "cart")
                        .tag(.cart)
                        .badge(text: badgeText)
                    
                    TabBarItem(selectedTab: selectedTab, label: "New", systemImage: "externaldrive.badge.plus")
                        .tag(.remote)
                }
                .frame(height: 56)
                .background(Color.white)
            }
        }
    }
}

extension View {
    @inlinable
    public func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        
        body(&result)
        
        return result
    }
}
