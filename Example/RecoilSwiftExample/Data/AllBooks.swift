import RecoilSwift

struct AllBook {
  // Atom
  static let allBookState = atom { [Book]() }

  // Action
  static func addBook(context: RecoilCallbackContext, newBook: Book) {
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
}
