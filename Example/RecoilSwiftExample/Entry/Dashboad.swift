import SwiftUI

struct Dashboard: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Example with SwiftUI")) {
                    NavigationLink("BookShop") {
                        MainTabPage()
                    }
                }
                
                Section(header: Text("Example with SwiftUI Hooks")) {
                    NavigationLink("Add Book") {
                        RemoteControllView()
                    }
                }
                
                Section(header: Text("Example with UIKIT")) {
                    NavigationLink("Come Soon..") {
                        EmptyView()
                    }
                }
                
                Section(header: Text("DebugTool")) {
                    NavigationLink("Come Soon..") {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Examples")
        }
    }
}
