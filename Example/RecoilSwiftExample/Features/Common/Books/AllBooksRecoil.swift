import RecoilSwift

// MARK: - Atom
struct AllBooks {
  static let allBookState = atom { [Book]() }
}

// MARK: - Action
extension AllBooks {
  static func addNew(context: RecoilCallbackContext, newBook: Book) {
    let books = context.get(allBookState)
    let isAdded = books.contains { $0.name == newBook.name }
    
    if !isAdded {
      context.set(allBookState, books + [newBook])
    }
  }
  
  /// You also can create a custom hooks like this:
  /// static func useAddBook() -> (Book) -> Void {
  ///    useRecoilCallback { context, newBook in
  ///      let books = context.get(allBookState)
  ///     let isAdded = books.contains { $0.name == newBook.name }
  ///
  ///      if !isAdded {
  ///        context.set(allBookState, books + [newBook])
  ///      }
  ///    }
  ///  }
  ///
  
  static func getFromRemote(_ context: RecoilCallbackContext) {
    // let someValue = context.get(someAtom)
    AllBooksService.getAllBooks()
      .sink(receiveCompletion: { _ in },
            receiveValue: { context.set(allBookState, $0) })
      .store(in: context)
  }
}
