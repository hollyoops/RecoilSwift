import SwiftUI
import RecoilSwift

public struct MainTabPage: View {
    @RecoilScope var recoil
    
    public var body: some View {
        let selectedTab = recoil.useBinding(SelectedTabState(), default: .list)
        let shouldShowFilter = recoil.useValue(Home.filterVisisbleState)
        let badgeText = try? recoil.useThrowingValue(Cart.cartItemBadgeState)
       
        ZStack(alignment: .bottom) {
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
                    .badge(badgeText)
            }.toolbar {
                if shouldShowFilter == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(
                            "Filter",
                            destination: FilterOptionsView())
                    }
                }
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
