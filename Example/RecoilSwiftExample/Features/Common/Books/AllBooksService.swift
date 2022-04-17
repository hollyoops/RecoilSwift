import Foundation
import Combine

enum BookError: Error { }

struct AllBooksService {
  static func getAllBooks() -> AnyPublisher<[Book], BookError> {
      Deferred {
          Future { promise in
              DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  promise(.success(Mocks.ALL_BOOKS))
              }
          }
      }.eraseToAnyPublisher()
  }
}
