import SwiftUI
import RecoilSwift

struct AllBooksView: HookView {
    var hookBody: some View {
        let currentBooks = useRecoilValue(BookList.currentBooks)
        
        NavigationView {
            TabBarReader { tabBar in
                BooksContent()
                    .navigationTitle("Book shop")
                    .onAppear {
                        tabBar?.isHidden = false
                    }
                    .ifTrue(!currentBooks.isEmpty) {
                        $0.navigationBarItems(
                            trailing: NavigationLink(
                                "Filter",
                                destination: FilterOptionsView().onAppear {
                                tabBar?.isHidden = true
                            })
                        )
                    }
            }
        }
    }
}

extension View {
    func ifTrue<T: View>(_ condition: Bool, _ transform: (Self) -> T) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}
