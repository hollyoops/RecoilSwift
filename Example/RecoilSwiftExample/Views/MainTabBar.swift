import SwiftUI

public struct MainTabBar: View {
    public var body: some View {
        VStack {
            Text(verbatim:"Recoil Swift")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
            
            TabView {
                AllBooksView()
                  .tabItem {
                      Text("All")
                  }
                
                CategoryView()
                  .tabItem {
                      Text("Category")
                  }
                
                RemoteBooksView()
                  .tabItem {
                      Text("Names")
                  }
            }
        }
    }
}
