import RecoilSwift

// MARK: - Atoms
struct BookList {
  static let selectedCategoryState = Atom<BookCategory?>(nil)
  static let selectedQuarterState = Atom<Int?>(nil)
}

// MARK: - Selectors
extension BookList {
  static let currentBooks = selector { get -> [Book] in
    let books = get(AllBooks.allBookState) ?? []
    if let category = get(selectedCategoryState) {
      return books.filter { $0.category == category }
    }
    return books
  }
}
