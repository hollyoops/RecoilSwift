import Foundation
import RecoilSwift

struct Cart {}

extension Cart {
  static let allCartItemState = atom { [CartItem]() }
}

extension Cart {
  static func addToCart(context: RecoilCallbackContext, newBook: Book) {
    let items = context.get(allCartItemState)
    
    if var item = items.first(where: { $0.id == newBook.id }) {
      item.count += 1
      context.set(allCartItemState, items.map { $0.id == item.id ? item: $0 })
    } else {
      let newItem = CartItem(book: newBook, count: 1)
      context.set(allCartItemState, items + [newItem])
    }
  }
  
  static func increasItemCount(context: RecoilCallbackContext, item: CartItem) {
    let items = context.get(allCartItemState)
    guard var itm = items.first(where: { $0.id == item.id }) else { return }
    itm.count += 1
    context.set(allCartItemState, items.map { $0.id == itm.id ? itm: $0 })
  }
  
  static func decreasItemCount(context: RecoilCallbackContext, item: CartItem) {
    var items = context.get(allCartItemState)
    guard var itm = items.first(where: { $0.id == item.id }) else { return }
    itm.count -= 1
    if itm.count <= 0 {
      items.removeAll(where: { $0.id == itm.id })
    }
    context.set(allCartItemState, items.map { $0.id == itm.id ? itm: $0 })
  }
}
