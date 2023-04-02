import RecoilSwift

// MARK: - Atoms
struct BookList {
    static var selectedCategoryState: Atom<BookCategory?> {
        atom(nil)
    }
    static var selectedQuarterState: Atom<Int?> {
        atom(nil)
    }
}

// MARK: - Selectors
extension BookList {
    static var currentBooks: AsyncSelector<[Book]> {
        selector { accessor -> [Book] in
            let books = try await accessor.get(AllBooks.allBookState)
            if let category = try accessor.get(selectedCategoryState) {
                return books.filter { $0.category == category }
            }
            return books
        }
    }
}
