import Foundation
import Combine

struct BookListService {
  static func getALLBooks() -> AnyPublisher<[Book], BookError> {
      Deferred {
          Future { promise in
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  promise(.success(Mocks.ALL_BOOKS))
              }
          }
      }.eraseToAnyPublisher()
  }
}
