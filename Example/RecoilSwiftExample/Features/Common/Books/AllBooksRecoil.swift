import RecoilSwift

// MARK: - Atom
struct AllBooks {
    static let allBookState = atom { AllBooksService.getAllBooks() }
}

// MARK: - Action
extension AllBooks {
    static func addNew(context: RecoilCallbackContext, newBook: Book) async throws -> Bool {
        let books = try await context.accessor.get(allBookState)
        let isAdded = books.contains { $0.name == newBook.name }
        
        if !isAdded {
            context.accessor.set(allBookState, books + [newBook])
            return true
        }
        
        return false
    }
    
    /// You also can create a custom hooks like this:
    /// static func useAddBook() -> (Book) -> Void {
    ///    useRecoilCallback { context, newBook in
    ///      let books = context.accessor.getUnsafe(allBookState)
    ///     let isAdded = books.contains { $0.name == newBook.name }
    ///
    ///      if !isAdded {
    ///        context.accessor.set(allBookState, books + [newBook])
    ///      }
    ///    }
    ///  }
    ///
    
    static func getFromRemote(_ context: RecoilCallbackContext) {
        // let someValue = context.accessor.getUnsafe(someAtom)
        AllBooksService.getAllBooks()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { context.accessor.set(allBookState, $0) })
            .store(in: context)
    }
}
