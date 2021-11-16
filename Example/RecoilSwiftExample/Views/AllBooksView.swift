import SwiftUI
import RecoilSwift

struct AllBooksView: HookView {
    var hookBody: some View {
        let callback = useRecoilCallback { context in
            // let someValue = context.get(someAtom)
            BookShop.getALLBooks()
                .sink(receiveCompletion: { _ in },
                      receiveValue: { context.set(BookShop.allBookState, $0) })
                .store(in: context)
        }
        
        return VStack {
            Button("fetch books") {
                callback()
            }
            
            allBooks
        }
        .padding()
    }
    
    @ViewBuilder private var allBooks: some View {
        let currentBooks = useRecoilValue(BookShop.currentBooks)
        
        VStack {
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
