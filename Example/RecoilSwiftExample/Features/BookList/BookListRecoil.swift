import RecoilSwift

// MARK: - Atoms
struct BookList {
    static let selectedCategoryState = Atom<BookCategory?>(nil)
    static let selectedQuarterState = Atom<Int?>(nil)
}

// MARK: - Selectors
extension BookList {
    static let currentBooks = selector { accessor -> [Book] in
        let books = try await accessor.get(AllBooks.allBookState)
        if let category = try accessor.get(selectedCategoryState) {
            return books.filter { $0.category == category }
        }
        return books
    }
}
