import Foundation

#if canImport(Combine)
import Combine
#endif

// MARK: - Sync Selector
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
public struct Selector<T: Equatable>: SyncSelectorReadable {
    public typealias T = T
    public typealias E = Never
    
    public let key: String
    public let get: any Evaluator<T>
    
    init(key: String = "R-Sel-\(UUID())", body: @escaping SyncGetFunc<T>) {
        self.key = key
        self.get = SyncGetBody({ try body(Getter(key)) })
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
public struct MutableSelector<T: Equatable>: SyncSelectorReadable {
    public typealias T = T
    public typealias E = Never
    
    public let key: String
    public let get: any Evaluator<T>
    public let set: SetBody<T>

    public init(key: String = "WR-Sel-\(UUID())", get: @escaping SyncGetFunc<T>, set: @escaping SetBody<T>) {
        self.key = key
        self.get = SyncGetBody({ try get(Getter(key)) })
        self.set = set
    }
}

extension MutableSelector: RecoilWriteable {
    public func update(with value: T) {
        let context = MutableContext(
            get: Getter(key),
            set: Setter(key))
        set(context, value)
    }
}

// MARK: - Async Selector

/// A ``AsyncSelector`` is a pure function that other async selectors as input. those selector be impletemented
/// by ``Combine`` or ``async/await``
/// ``Selector`` and ``AsyncSelector`` can not allow you pass a user-defined argument, if you want to pass a
/// customable parameters. please refer to ``selectorFamily``

public struct AsyncSelector<T: Equatable>: AsyncSelectorReadable {
    public let key: String
    public let get: any Evaluator<T>

    public init<E: Error>(key: String = "R-AsyncSel-\(UUID())", get: @escaping CombineGetFunc<T, E>) {
        self.key = key
        self.get = CombineGetBody<T, E>( { try get(Getter(key)) })
    }
    
    public init(key: String = "R-AsyncSel-\(UUID())", get: @escaping AsyncGetFunc<T>) {
        self.key = key
        self.get = AsyncGetBody<T>({ try await get(Getter(key))})
    }
}

// TODO: Not support yet
//
//public struct MutableAsyncSelector<T: Equatable, E: Error>: RecoilAsyncValue {
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
//
//extension MutableAsyncSelector: RecoilSyncWriteable { }
