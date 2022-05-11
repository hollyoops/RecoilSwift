import SwiftUI
import RecoilSwift

struct RemoteControllView: HookView {
    let isTabbarVisible = useRecoilState(Home.tabBarVisibleState)
    
    var hookBody: some View {
        NavigationView {
            AddBookView()
                .navigationBarTitle("New Book")
                .navigationBarItems(
                    trailing: NavigationLink(
                        destination: MoreUsageView().onAppear {
                            isTabbarVisible.wrappedValue = false
                        }.onDisappear {
                            isTabbarVisible.wrappedValue = true
                        }) {
                            Label("", systemImage: "ellipsis")
                        }
                )
        }
    }
}
