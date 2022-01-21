import SwiftUI

public struct MainTabBar: View {
    public var body: some View {
        TabView {
            AllBooksView()
                .tabItem {
                    Label("Books", systemImage: "books.vertical")
                }
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
            
            RemoteControllView()
                .tabItem {
                    Label("Remote", systemImage: "externaldrive.badge.icloud")
                }
        }
    }
}
