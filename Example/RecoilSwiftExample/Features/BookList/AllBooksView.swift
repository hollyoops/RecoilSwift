import SwiftUI
import RecoilSwift

struct AllBooksView: HookView {
    @State var isFilterVisible = false
    
    var hookBody: some View {
        let currentBooks = useRecoilValue(BookShop.currentBooks)
        let selectedCategoryState = useRecoilState(BookShop.selectedCategoryState)
        
        NavigationView {
            BooksContent()
                .actionSheet(isPresented: $isFilterVisible) {
                    filterSheet(currentCategory: selectedCategoryState)
                }
                .navigationTitle("Book shop")
                .ifTrue(!currentBooks.isEmpty) {
                    $0.navigationBarItems(
                        trailing: Button("Filter") {
                            isFilterVisible = true
                        }
                    )
                }
        }
    }
    
    private func filterSheet(currentCategory: Binding<BookCategory?>) -> ActionSheet {
        let actions: [ActionSheet.Button] = BookCategory.allCases.map { category in
                .default(Text(category.rawValue.capitalized)) {
                    currentCategory.wrappedValue = category
                }
        }
        
        return ActionSheet(
            title: Text("Choose a category"),
            buttons: actions + [
                .destructive(Text("Clear")) {
                    currentCategory.wrappedValue = nil
                },
                .cancel()]
        )
    }
}

extension View {
    func ifTrue<T: View>(_ condition: Bool, _ transform: (Self) -> T) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}
