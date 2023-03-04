import Foundation

#if canImport(Combine)
import Combine
#endif

// MARK: - Sync Selector
public typealias SetBody<T> = (MutableContext, T) -> Void

public typealias CombineGet<T: Equatable, E: Error> = (StateGetter) throws -> AnyPublisher<T, E>

public typealias SyncGet<T> = (StateGetter) throws -> T

public typealias AsyncGet<T: Equatable> = (StateGetter) async throws -> T


/// A Selector represent a derived state in Recoil. If only a get function is provided, the selector is read-only and returns a ``Readonly Selector``
/// - Parameters:
///  - getBody: A synchronous function that evaluates the value for the derived state.
/// - Returns: A synchronous readonly selector.
public func selector<T: Equatable>(_ getBody: @escaping SyncGet<T>,
                                   fileID: String = #fileID,
                                   line: Int = #line) -> Selector<T> {
    Selector(body: getBody, fileID: fileID, line: line)
}

/// A Selector represent a derived state in Recoil. If only a get function is provided, the selector is read-only and returns a ``Readonly Selector``
/// - Parameters:
///  - getBody:  A asynchronous function that evaluates the value for the derived state. It return ``AnyPublisher`` object.
/// - Returns: A asynchronous readonly selector with combine.

public func selector<T: Equatable, E: Error>(_ getBody: @escaping CombineGet<T, E>,
                                             fileID: String = #fileID,
                                             line: Int = #line) -> AsyncSelector<T> {
    AsyncSelector(get: getBody, fileID: fileID, line: line)
}

/// A Selector represent a derived state in Recoil. If only a get function is provided, the selector is read-only and returns a ``Readonly Selector``
/// - Parameters:
///  - getBody:  A async function that evaluates the value for the derived state.
/// - Returns: A asynchronous readonly selector with ``async/await``.

public func selector<T: Equatable>(_ getBody: @escaping AsyncGet<T>,
                                   fileID: String = #fileID,
                                   line: Int = #line) -> AsyncSelector<T> {
    AsyncSelector(get: getBody, fileID: fileID, line: line)
}

/// A Selector represent a derived state in Recoil. If the get and set function are provided, the selector is writeable
/// - Parameters:
///  - get: A synchronous function that evaluates the value for the derived state.
///  - set: A synchronous function that can store a value to Recoil object
/// - Returns: A asynchronous readonly selector with ``async/await``.
public func selector<T: Equatable>(get getBody: @escaping SyncGet<T>,
                                   set setBody: @escaping SetBody<T>,
                                   fileID: String = #fileID,
                                   line: Int = #line) -> MutableSelector<T> {
    return MutableSelector(get: getBody, set: setBody, fileID: fileID, line: line)
}



///A ``selector`` is a pure function that accepts atoms or other sync selectors as input. When these upstream atoms or sync selectors are updated, the selector function will be re-evaluated. Components can subscribe to selectors just like atoms, and will then be re-rendered when the selectors change.

/// **Selectors** are used to calculate derived data that is based on state. This lets us avoid redundant state because a minimal set of state is stored in atoms, while everything else is efficiently computed as a function of that minimal state.
///
///```swift
/// let currentBooksSel = selector { accessor -> [Book] in
///    let books = accessor.get(allBookStore)
///      if let category = accessor.get(selectedCategoryState) {
///          return books.filter { $0.category == category }
///      }
///    return books
///}
///```
public struct Selector<T: Equatable>: SyncSelectorNode {
    public typealias T = T
    public typealias E = Never
    
    public let key: NodeKey
    public let get: (StateGetter) throws -> T
    
    init(key: NodeKey, body: @escaping SyncGet<T>) {
        self.key = key
        self.get = body
    }
    
    init(body: @escaping SyncGet<T>, fileID: String = #fileID, line: Int = #line) {
        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
        self.init(key: NodeKey(name: keyName), body: body)
    }
    
    public func compute(_ accessor: StateGetter) throws -> T {
        try get(accessor)
    }
}

/// ``MutableSelector`` is a bi-directional sync selector receives the incoming value as a parameter and can use that to propagate the changes back upstream along the data-flow graph.

///```swift
/// let tempFahrenheitState = atom(32)
/// let tempCelsiusSelector = selector(
///      get: { get in
///        let fahrenheit = accessor.get(tempFahrenheitState)
///        return (fahrenheit - 32) * 5 / 9
///      },
///      set: { context, newValue in
///        let newFahrenheit = (newValue * 9) / 5 + 32
///        context.accessor.set(tempFahrenheitState, newFahrenheit)
///      }
///)
///```
public struct MutableSelector<T: Equatable>: SyncSelectorNode {
    public typealias T = T
    public typealias E = Never
    
    public let key: NodeKey
    public let get: (StateGetter) throws -> T
    public let set: SetBody<T>

    public init(key: NodeKey, get: @escaping SyncGet<T>, set: @escaping SetBody<T>) {
        self.key = key
        self.get = get
        self.set = set
    }
    
    public init(get: @escaping SyncGet<T>,
                set: @escaping SetBody<T>,
                fileID: String = #fileID,
                line: Int = #line) {
        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
        self.init(key: NodeKey(name: keyName), get: get, set: set)
    }
    
    public func compute(_ accessor: StateGetter) throws -> T {
        try get(accessor)
    }
}

extension MutableSelector: Writeable {
    public func update(context: MutableContext, newValue: T) {
        set(context, newValue)
    }
}

// MARK: - Async Selector

/// A ``AsyncSelector`` is a pure function that other async selectors as input. those selector be impletemented
/// by ``Combine`` or ``async/await``
/// ``Selector`` and ``AsyncSelector`` can not allow you pass a user-defined argument, if you want to pass a
/// customable parameters. please refer to ``selectorFamily``

public struct AsyncSelector<T: Equatable>: AsyncSelectorNode {
    public let key: NodeKey
    public let get: (StateGetter) async throws -> T

    public init<E: Error>(key: NodeKey, get: @escaping CombineGet<T, E>) {
        self.key = key
        self.get = { try await get($0).async() }
    }
    
    public init(key: NodeKey, get: @escaping AsyncGet<T>) {
        self.key = key
        self.get = get
    }
    
    public init(get: @escaping AsyncGet<T>, fileID: String = #fileID, line: Int = #line) {
        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
        self.init(key: NodeKey(name: keyName), get: get)
    }
    
    public init<E: Error>(get: @escaping CombineGet<T, E>, fileID: String = #fileID, line: Int = #line) {
        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
        self.init(key: NodeKey(name: keyName), get: get)
    }
    
    public func compute(_ accessor: StateGetter) async throws -> T {
        try await get(accessor)
    }
}

// TODO: Not support yet
//
//public struct MutableAsyncSelector<T: Equatable, E: Error>: RecoilAsyncValue {
//    public let key: AnyNodeKey
//    public let get: AsyncGet
//    public let set: SetBody<T?>
//
//    public init(key: AnyNodeKey,
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
