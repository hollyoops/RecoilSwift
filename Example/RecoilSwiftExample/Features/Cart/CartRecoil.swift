import Foundation
import RecoilSwift

struct Cart {}

extension Cart {
  static let allCartItemState = atom { [CartItem]() }
}

extension Cart {
  static func addToCart(context: RecoilCallbackContext, newBook: Book) {
    let books = context.get(allCartItemState)
    
    if var item = books.first(where: { $0.id == newBook.id }) {
      item.count += 1
      context.set(allCartItemState, books.map { $0.id == item.id ? item: $0 })
    } else {
      let newItem = CartItem(book: newBook, count: 1)
      context.set(allCartItemState, books + [newItem])
    }
  }
}

