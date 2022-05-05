import SwiftUI

struct RemoteControllView: View {
    var body: some View {
        NavigationView {
            TabBarReader { tabBar in
                
                AddBookView()
                    .navigationBarTitle("New Book")
                    .navigationBarItems(
                        trailing: NavigationLink(
                            destination: MoreUsageView().onAppear {
                                tabBar?.isHidden = true
                            }) {
                            Label("", systemImage: "ellipsis")
                        }
                    ).onAppear {
                        tabBar?.isHidden = false
                    }
            }
        }
    }
}
