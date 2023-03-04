import Foundation
import RecoilSwift

struct Cart {}

extension Cart {
  static let allCartItemState = atom { [CartItem]() }
    
  static let cartItemBadgeState = selector { accessor -> String? in
      let items = try accessor.get(allCartItemState)
      let count = items.reduce(into: 0) { result, item in
          result += item.count
      }
    
      if count <= 0 {
          return nil
      }

      return count < 10 ? "\(count)" : "9+"
  }
}

extension Cart {
  static func addToCart(context: RecoilCallbackContext, newBook: Book) {
    let items = context.accessor.getUnsafe(allCartItemState)
    
    if var item = items.first(where: { $0.id == newBook.id }) {
      item.count += 1
      context.accessor.set(allCartItemState, items.map { $0.id == item.id ? item: $0 })
    } else {
      let newItem = CartItem(book: newBook, count: 1)
      context.accessor.set(allCartItemState, items + [newItem])
    }
  }
  
  static func increasItemCount(context: RecoilCallbackContext, item: CartItem) {
    let items = context.accessor.getUnsafe(allCartItemState)
    guard var itm = items.first(where: { $0.id == item.id }) else { return }
    itm.count += 1
    context.accessor.set(allCartItemState, items.map { $0.id == itm.id ? itm: $0 })
  }
  
  static func decreasItemCount(context: RecoilCallbackContext, item: CartItem) {
    var items = context.accessor.getUnsafe(allCartItemState)
    guard var itm = items.first(where: { $0.id == item.id }) else { return }
    itm.count -= 1
    if itm.count <= 0 {
      items.removeAll(where: { $0.id == itm.id })
    }
    context.accessor.set(allCartItemState, items.map { $0.id == itm.id ? itm: $0 })
  }
  
  static func deleteItem(context: RecoilCallbackContext, atIndex index: IndexSet) {
    var items = context.accessor.getUnsafe(allCartItemState)
    items.remove(atOffsets: index)
    context.accessor.set(allCartItemState, items)
  }
}
