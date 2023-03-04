import SwiftUI
import RecoilSwift

struct BooksContent: HookView {
    
    @MainActor
    var hookBody: some View {
        //    let callback = useRecoilCallback(AllBooks.getFromRemote)
        let loadable = useRecoilValueLoadable(BookList.currentBooks)
        
        return VStack {
            if loadable.isLoading {
                Text("Fetch books...")
                ProgressView()
                    .padding(.vertical, 10)
            } else if let currentBooks = loadable.data {
                VStack(alignment: .leading, spacing: 8) {
                    FilterInfoView()
                        .padding([.leading], 24)
                    allBooks(books: currentBooks)
                }
            }
        }
    }
    
    @MainActor
    private func allBooks(books: [Book]) -> some View {
        let addToCart = useRecoilCallback(Cart.addToCart(context:newBook:))
        return List(books) { book in
            HStack {
                VStack(alignment: .leading) {
                    Text(book.name)
                    Spacer()
                    Text("Category: \(book.category.rawValue)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Button(action: {
                    addToCart(book)
                }) {
                    Image(systemName: "cart.fill.badge.plus")
                        .resizable()
                        .frame(width: 32.0, height: 26.0)
                }
            }
            .padding()
            .buttonStyle(PlainButtonStyle())
        }
    }
}
