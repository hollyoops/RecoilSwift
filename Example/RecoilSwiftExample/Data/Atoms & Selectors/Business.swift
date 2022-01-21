import RecoilSwift

extension BookShop {
  static let currentBooks = selector { get -> [Book] in
    let books = get(AllBook.allBookState)
    if let category = get(selectedCategoryState) {
      return books.filter { $0.category == category }
    }
    return books
  }
}
