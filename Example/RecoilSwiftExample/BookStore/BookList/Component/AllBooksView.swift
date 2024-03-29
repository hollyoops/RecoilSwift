import SwiftUI
import RecoilSwift

struct AllBooksView: View {
    @RecoilScope var recoil
    
    var body: some View {
        let currentBooks = recoil.useLoadable(BookList.currentBooks).data ?? []
        
        BooksContent()
            .navigationTitle("Book shop")
            .ifTrue(!currentBooks.isEmpty) {
                $0.navigationBarItems(
                    trailing: NavigationLink(
                        "Filter",
                        destination: FilterOptionsView())
                )
            }
    }
}

extension View {
    func ifTrue<T: View>(_ condition: Bool, _ transform: (Self) -> T) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}
