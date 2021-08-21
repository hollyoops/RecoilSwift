import Foundation
import Combine
import RecoilSwift

struct BookShop {}

// Atoms
extension BookShop {
    static let selectedQuarterStore = Atom<Int?>(nil)
    static let allBookStore = atom { [Book]() }
    static let selectedCategoryState = Atom<BookCategory?>(nil)
}

enum BookError: Error { }

// Selectors
extension BookShop {
    static let currentBooksSel = selector { get -> [Book] in
        let books = get(allBookStore)
        if let category = get(selectedCategoryState) {
            return books.filter { $0.category == category }
        }
        return books
    }

    static let fetchRemoteBookNamesByCategory = selectorFamily { (category: String, get: ReadOnlyContext) -> AnyPublisher<[String], BookError> in
        func buildPromise(_ values: [String]) -> AnyPublisher<[String], BookError> {
            Deferred {
                Future { promise in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        promise(.success(values))
                    }
                }
            }.eraseToAnyPublisher()
        }

        return buildPromise(["\(category):Book1", "\(category):Book2"])
    }
    
    static let getLocalBookNames = selectorFamily { (category: String, get: ReadOnlyContext) -> [String] in
        ["local:\(category):Book1", "local:\(category):Book2"]
    }
}
