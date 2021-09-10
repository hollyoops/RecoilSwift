import SwiftUI
import RecoilSwift
import Combine

struct ContentView: HookView {
    var hookBody: some View {
        let callback = useRecoilCallback { context in
            // let someValue = context.get(someAtom)
            
            BookShop.getALLBooks()
                .sink(receiveCompletion: { _ in }, receiveValue: { context.set(BookShop.allBookState, $0) })
                .store(in: context)
        }
        
        return VStack {
            Button("fetch books") {
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
                Text("Automatic fetching names...")
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
        let currentBooks = useRecoilValue(BookShop.currentBooks)
        
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

