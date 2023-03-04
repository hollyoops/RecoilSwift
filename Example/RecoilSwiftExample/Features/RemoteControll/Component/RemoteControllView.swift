import SwiftUI
import RecoilSwift

struct RemoteControllView: HookView {
    @MainActor
    var hookBody: some View {
        let isTabbarVisible = useRecoilState(Home.tabBarVisibleState)
        NavigationView {
            AddBookView()
                .navigationBarTitle("Add local book")
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
