import RecoilSwift
import Combine

extension BookShop {
    @available(iOS 15.0, *)
    static let fetchRemoteBookNamesByCategory = selectorFamily { (category: String, get: Getter) async -> [String] in
        // let value = get(someAtom)
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return ["\(category):Book1", "\(category):Book2"]
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
