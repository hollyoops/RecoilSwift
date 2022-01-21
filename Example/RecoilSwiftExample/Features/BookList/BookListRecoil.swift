import RecoilSwift

// Atoms
struct BookList {
  static let selectedCategoryState = Atom<BookCategory?>(nil)
  static let selectedQuarterState = Atom<Int?>(nil)
}

// Selectors
extension BookList {
  static let currentBooks = selector { get -> [Book] in
    let books = get(AllBook.allBookState)
    if let category = get(selectedCategoryState) {
      return books.filter { $0.category == category }
    }
    return books
  }
}

// MARK: - Actions
extension BookList {
  static func getRemoteBooks(_ context: RecoilCallbackContext) {
    // let someValue = context.get(someAtom)
     BookListService.getALLBooks()
           .sink(receiveCompletion: { _ in },
                 receiveValue: { context.set(AllBook.allBookState, $0) })
           .store(in: context)
  }
}



