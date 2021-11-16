import RecoilSwift

extension BookShop {
    static let currentBooks = selector { get -> [Book] in
        let books = get(allBookState)
        if let category = get(selectedCategoryState) {
            return books.filter { $0.category == category }
        }
        return books
    }
}
