import SwiftUI
import RecoilSwift

struct BooksContent: HookView {
  var hookBody: some View {
    let callback = useRecoilCallback(AllBooks.getFromRemote)
    let currentBooks = useRecoilValue(BookList.currentBooks)
    
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
    let addToCart = useRecoilCallback(Cart.addToCart(context:newBook:))
    return List(books) { book in
      HStack {
        Text(book.name + "(\(book.category.rawValue))")
        Spacer()
        Button(action: {
          addToCart(book)
        }) {
          Text("Add")
            .font(Font.system(size: 12))
        }
        .frame(width: 35)
        .background(Color.gray)
        .cornerRadius(5)
      }
      .padding()
      .buttonStyle(PlainButtonStyle())
    }
  }
}