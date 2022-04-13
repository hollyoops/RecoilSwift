import SwiftUI
import RecoilSwift

struct BooksContent: HookView {
  var hookBody: some View {
//    let callback = useRecoilCallback(AllBooks.getFromRemote)
    let loadable = useRecoilValueLoadable(BookList.currentBooks)
    
    return VStack {
      if loadable.isLoading {
        Text("Automatic fetching names...")
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
