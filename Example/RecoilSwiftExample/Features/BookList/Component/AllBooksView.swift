import SwiftUI
import RecoilSwift

struct AllBooksView: HookView {
    @MainActor
    var hookBody: some View {
        let currentBooks = useRecoilValueLoadable(BookList.currentBooks).data ?? []
        let isTabbarVisible = useRecoilState(Home.tabBarVisibleState)
        
        NavigationView {
            BooksContent()
                .navigationTitle("Book shop")
                .ifTrue(!currentBooks.isEmpty) {
                    $0.navigationBarItems(
                        trailing: NavigationLink(
                            "Filter",
                            destination: FilterOptionsView().onAppear {
                                isTabbarVisible.wrappedValue = false
                            }.onDisappear {
                                isTabbarVisible.wrappedValue = true
                            })
                    )
                }
            
        }
    }
}

extension View {
    func ifTrue<T: View>(_ condition: Bool, _ transform: (Self) -> T) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}
