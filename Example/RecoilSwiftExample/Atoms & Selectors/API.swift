import RecoilSwift
import Combine

extension BookShop {
    static let fetchRemoteBookNamesByCategory = selectorFamily { (category: String, get: Getter) -> AnyPublisher<[String], BookError> in
        // let value = get(someAtom)
        getRemoteBookNames(by: category)
    }
}

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
