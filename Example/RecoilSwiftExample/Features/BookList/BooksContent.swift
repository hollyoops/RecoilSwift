import SwiftUI
import RecoilSwift

struct BooksContent: HookView {
    var hookBody: some View {
        let callback = useRecoilCallback { context in
            // let someValue = context.get(someAtom)
            BookShop.getALLBooks()
                .sink(receiveCompletion: { _ in },
                      receiveValue: { context.set(BookShop.allBookState, $0) })
                .store(in: context)
        }
        
        let currentBooks = useRecoilValue(BookShop.currentBooks)
        
        return VStack {
            if currentBooks.isEmpty {
                Button("Tap to fetch books") {
                    callback()
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    FilterInfoView()
                        .padding([.leading], 24)
                    allBooks(books: currentBooks)
                }
            }
        }
    }
    
    private func allBooks(books: [Book]) -> some View {
        List(books) { book in
            HStack {
                Text(book.name)
                Spacer()
                Text(book.category.rawValue)
            }
            .padding()
        }
    }
}
