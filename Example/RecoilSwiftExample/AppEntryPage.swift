import SwiftUI
import RecoilSwift

struct AppEntryPage: View {
    var body: some View {
        RecoilRoot {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        NavigationStack {
            List {
                Section(header: Text("Example with SwiftUI")) {
                    NavigationLink("BookShop") {
                        MainTabPage()
                    }
                }
                
                Section(header: Text("Example with SwiftUI Hooks")) {
                    NavigationLink("Add Book") {
                        AddBookView()
                    }
                }
                
                Section(header: Text("Example with UIKIT")) {
                    NavigationLink("Come Soon...") {
                        EmptyView()
                    }
                }
                
                Section(header: Text("DebugTool")) {
                    NavigationLink("Come Soon...") {
                        EmptyView()
                    }
                }
            }
            .navigationBarTitle("Recoil Examples", displayMode: .inline)
            .navigationBarItems(
                trailing: NavigationLink(
                    destination: MoreUsageView()) {
                        Label("", systemImage: "ellipsis")
                    }
            )
        }
    }
}

struct AppEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AppEntryPage()
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
