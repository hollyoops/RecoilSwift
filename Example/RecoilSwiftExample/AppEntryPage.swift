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
                    Button(action: {
                        let books = BooksViewController()
                        let viewController = UINavigationController(rootViewController: books)
                        UIApplication.present(viewController, animated: true)
                    }) {
                        Text("Show BooksViewController")
                    }
                }
                
                Section(header: Text("DebugTool")) {
                    NavigationLink("Snapshot") {
                        SnapshotTestView()
                    }

                    NavigationLink("Time travel(Come Soon...)") {
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
