import Foundation
import Combine

/// Atoms are units of state. They're updatable and subscribable: when an atom is updated, each subscribed component is re-rendered with the new value.
///
/// They can be created at runtime, too. Atoms can be used in place of local component state. If the same atom is used  from multiple components, all those components share their state.
///
/// ```swift
/// let allBookState = atom { [Book]() }
/// ```
/// You can retrive value with ``Recoil hooks``,
/// eg: ``useRecoilState(allBookState)``
///

public typealias AtomCombineGet<T: Equatable, E: Error> = () throws -> AnyPublisher<T, E>

public typealias AtomAsyncGet<T: Equatable> = () async throws -> T

//MARK: - Atoms

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - value: The initial value of the atom
/// - Returns: A writeable RecoilState object.
public func atom<T: Equatable>(_ value: T,
                               funcName: String = #function,
                               fileID: String = #fileID,
                               line: Int = #line) -> Atom<T> {
    let key = NodeKey(position: .init(funcName: funcName, fileName: fileID, line: line), type: .atom)
    return Atom(key: key, value: value)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.
public func atom<T: Equatable>(_ fn: @escaping () throws -> T,
                               funcName: String = #function,
                               fileID: String = #fileID,
                               line: Int = #line) -> Atom<T> {
    let key = NodeKey(position: .init(funcName: funcName, fileName: fileID, line: line), type: .atom)
    return Atom(key: key, get: fn)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.

public func atom<T: Equatable, E: Error>(_ fn: @escaping AtomCombineGet<T, E>,
                                         funcName: String = #function,
                                         fileID: String = #fileID,
                                         line: Int = #line) -> AsyncAtom<T> {
    let key = NodeKey(position: .init(funcName: funcName, fileName: fileID, line: line), type: .atom)
    return AsyncAtom(key: key, get: fn)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.

public func atom<T: Equatable>(_ fn: @escaping AtomAsyncGet<T>,
                               funcName: String = #function,
                               fileID: String = #fileID,
                               line: Int = #line) -> AsyncAtom<T> {
    let key = NodeKey(position: .init(funcName: funcName, fileName: fileID, line: line), type: .atom)
    return AsyncAtom(key: key, get: fn)
}

public struct Atom<T: Equatable>: SyncAtomNode, Writeable {
    public typealias T = T
    public typealias E = Never
    
    public let key: NodeKey
    public let get: () throws -> T
    
    public init(key: NodeKey, value: T) {
        self.key = key
        self.get = { value }
    }
    
    public init(key: NodeKey, get: @escaping () throws -> T) {
        self.key = key
        self.get = get
    }
    
//    public init(get: @escaping () throws -> T, fileID: String = #fileID, line: Int = #line) {
//        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
//        self.init(key: NodeKey(name: keyName), get: get)
//    }
//
//    public init(_ value: T, fileID: String = #fileID, line: Int = #line) {
//        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
//        self.init(key: NodeKey(name: keyName), value)
//    }
    
    public func getValue() throws -> T {
        try get()
    }
}

public struct AsyncAtom<T: Equatable>: AsyncAtomNode, Writeable {
    public let key: NodeKey
    public var get: () async throws -> T
    
    public init<E: Error>(key: NodeKey, get: @escaping AtomCombineGet<T, E>) {
        self.key = key
        self.get = { try await get().async() }
    }
    
    public init(key: NodeKey, get: @escaping AtomAsyncGet<T>) {
        self.key = key
        self.get = { try await get() }
    }
    
//    public init<E: Error>(get: @escaping AtomCombineGet<T, E>, fileID: String = #fileID, line: Int = #line) {
//        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
//        self.init(key: NodeKey(name: keyName), get: get)
//    }
//
//    public init(get: @escaping AtomAsyncGet<T>, fileID: String = #fileID, line: Int = #line) {
//        let keyName = sourceLocationKey(Self.self, fileName: fileID, line: line)
//        self.init(key: NodeKey(name: keyName), get: get)
//    }
    
    public func getValue() async throws -> T {
        try await get()
    }
}
