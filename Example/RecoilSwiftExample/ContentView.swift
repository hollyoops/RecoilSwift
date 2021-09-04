import SwiftUI
import RecoilSwift
import Combine

struct ContentView: HookView {
//    @RecoilValue(BookShop.currentBooksSel) var currentBooks: [Book]
//    @RecoilValue(BookShop.fetchRemoteBookNames) var bookNames: [String]?
//    @RecoilState(BookShop.allBookStore) var allBooks: [Book]
//    @RecoilState(BookShop.selectedCategoryState) var selectedCategoryState: BookCategory?

    var hookBody: some View {
        let callback = useRecoilCallback { context in
            // let someValue = context.get(someAtom)
            
            BookShop.getALLBooks()
                .sink(receiveCompletion: { _ in }, receiveValue: { context.set(BookShop.allBookStore, $0) })
                .store(in: context)
        }
        
        return VStack {
            Button("Get All Books") {
                callback()
            }
            renderCategoryTabs()
            renderBooks()
            renderRemoteBookNames()
        }
        .padding()
    }
    
    private func renderCategoryTabs() -> some View {
        let selectedCategoryState = useRecoilState(BookShop.selectedCategoryState)
        
        return HStack {
            ForEach(BookCategory.allCases, id: \.self) { category in
                Button(category.rawValue) {
                    print(category.rawValue)
                    selectedCategoryState.wrappedValue = category
                }.padding()
            }
        }
    }
    
    private func renderRemoteBookNames() -> some View {
        let selectedCategory = useRecoilValue(BookShop.selectedCategoryState)
        let categoryName = selectedCategory?.rawValue ?? "ALL"
        let loadable = useRecoilValueLoadable(BookShop.fetchRemoteBookNamesByCategory(categoryName))
        
        return VStack {
            if loadable.isLoading {
                ProgressView()
                    .padding(.vertical, 10)
            }
           
            if let names = loadable.data {
                ForEach(names, id: \.self) {
                    Text($0)
                }
            }
        }
    }

    private func renderBooks() -> some View {
        let currentBooks = useRecoilValue(BookShop.currentBooksSel)
        
       return VStack {
            ForEach(currentBooks, id: \.self) { book in
                HStack {
                    Text(book.name)
                    Spacer()
                    Text(book.category.rawValue)
                }
                .padding()
                .background(Color.yellow)
            }
        }
    }
}

