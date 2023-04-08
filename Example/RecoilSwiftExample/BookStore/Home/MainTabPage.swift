import SwiftUI
import RecoilSwift

public struct MainTabPage: View {
    @RecoilScope var ctx
    
    public var body: some View {
        let selectedTab = ctx.useRecoilState(SelectedTabState())
        let shouldShowFilter = ctx.useRecoilValue(Home.filterVisisbleState)
        let badgeText = ctx.useRecoilValue(Cart.cartItemBadgeState)
       
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
