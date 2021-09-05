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

// APIs
extension BookShop {
    static func getALLBooks() -> AnyPublisher<[Book], BookError> {
        Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    promise(.success(Mocks.ALL_BOOKS))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    static func getRemoteBookNames(by category: String) -> AnyPublisher<[String], BookError> {
        makePromise(["\(category):Book1", "\(category):Book2"])
    }
    
    private static func makePromise<T>(_ values: T) -> AnyPublisher<T, BookError> {
        Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    promise(.success(values))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// Selectors
extension BookShop {
    static let currentBooksSel = selector { get -> [Book] in
        let books = get(allBookStore)
        if let category = get(selectedCategoryState) {
            return books.filter { $0.category == category }
        }
        return books
    }

    static let fetchRemoteBookNamesByCategory = selectorFamily { (category: String, get: ReadonlyContext) -> AnyPublisher<[String], BookError> in
        // let value = get(someAtom)
        getRemoteBookNames(by: category)
    }
    
    static let getLocalBookNames = selectorFamily { (category: String, get: ReadonlyContext) -> [String] in
        ["local:\(category):Book1", "local:\(category):Book2"]
    }
}
