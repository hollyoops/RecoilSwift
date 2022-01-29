import Combine
import Foundation

struct MoreUsageService {
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
