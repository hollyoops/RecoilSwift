import Foundation

#if canImport(Combine)
import Combine
#endif

// MARK: - Sync Selector
public typealias GetBody<T> = (Getter) throws -> T
public typealias SetBody<T> = (MutableContext, T) -> Void

///A ``selector`` is a pure function that accepts atoms or other sync selectors as input. When these upstream atoms or sync selectors are updated, the selector function will be re-evaluated. Components can subscribe to selectors just like atoms, and will then be re-rendered when the selectors change.

/// **Selectors** are used to calculate derived data that is based on state. This lets us avoid redundant state because a minimal set of state is stored in atoms, while everything else is efficiently computed as a function of that minimal state.
///
///```swift
/// let currentBooksSel = selector { get -> [Book] in
///    let books = get(allBookStore)
///      if let category = get(selectedCategoryState) {
///          return books.filter { $0.category == category }
///      }
///    return books
///}
///```
public struct Selector<T: Equatable>: RecoilValue, RecoilSyncReadable {
    public let key: String
    public let get: GetBody<T>
    
    init(key: String = "R-Sel-\(UUID())", body: @escaping GetBody<T>) {
        self.key = key
        self.get = body
    }
}

/// ``MutableSelector`` is a bi-directional sync selector receives the incoming value as a parameter and can use that to propagate the changes back upstream along the data-flow graph.

///```swift
/// let tempFahrenheitState = atom(32)
/// let tempCelsiusSelector = selector(
///      get: { get in
///        let fahrenheit = get(tempFahrenheitState)
///        return (fahrenheit - 32) * 5 / 9
///      },
///      set: { context, newValue in
///        let newFahrenheit = (newValue * 9) / 5 + 32
///        context.set(tempFahrenheitState, newFahrenheit)
///      }
///)
///```
public struct MutableSelector<T: Equatable>: RecoilValue, RecoilSyncReadable {
    public let key: String
    public let get: GetBody<T>
    public let set: SetBody<T>

    public init(key: String = "WR-Sel-\(UUID())", get: @escaping GetBody<T>, set: @escaping SetBody<T>) {
        self.key = key
        self.get = get
        self.set = set
    }
}

extension MutableSelector: RecoilSyncWriteable { }

// MARK: - Async Selector
@available(iOS 13.0, *)
public typealias CombineGetBody<T: Equatable, E: Error> = (Getter) throws -> AnyPublisher<T, E>

@available(iOS 15.0, *)
public typealias AsyncGetBody<T: Equatable> = (Getter) async throws -> T


public protocol AsyncGet {
    func toLoader(for key: String) -> LoaderProtocol
}

@available(iOS 13.0, *)
struct CombineCallback<T: Equatable, E: Error>: AsyncGet {
    func toLoader(for key: String) -> LoaderProtocol {
        let getFn = self.get
        return CombineLoader { try getFn(Getter(key)) }
    }
    
    public let get: CombineGetBody<T, E>
}

@available(iOS 15.0, *)
struct AsyncCallback<T: Equatable>: AsyncGet {
    public let get: AsyncGetBody<T>
    
    func toLoader(for key: String) -> LoaderProtocol {
        let getFn = self.get
        return AsynchronousLoader { try await getFn(Getter(key)) }
    }
}

/// A ``AsyncSelector`` is a pure function that other async selectors as input. those selector be impletemented
/// by ``Combine`` or ``async/await``
/// ``Selector`` and ``AsyncSelector`` can not allow you pass a user-defined argument, if you want to pass a
/// customable parameters. please refer to ``selectorFamily``
@available(iOS 13.0, *)
public struct AsyncSelector<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
    public let key: String
    public let get: AsyncGet

    public init(key: String = "R-AsyncSel-\(UUID())", get: @escaping CombineGetBody<T, E>) {
        self.key = key
        self.get = CombineCallback(get: get)
    }
    
    @available(iOS 15.0, *)
    public init(key: String = "R-AsyncSel-\(UUID())", get: @escaping AsyncGetBody<T>) {
        self.key = key
        self.get = AsyncCallback(get: get)
    }
}

// TODO: Not support yet
//@available(iOS 13.0, *)
//public struct MutableAsyncSelector<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
//    public let key: String
//    public let get: AsyncGet
//    public let set: SetBody<T?>
//
//    public init(key: String = "WR-AsyncSel-\(UUID())",
//                get: @escaping CombineGetBody<T, E>,
//                set: @escaping SetBody<T?>) {
//        self.key = key
//        self.get = CombineCallback(get: get)
//        self.set = set
//    }
//}
//
//@available(iOS 13.0, *)
//extension MutableAsyncSelector: RecoilSyncWriteable { }
