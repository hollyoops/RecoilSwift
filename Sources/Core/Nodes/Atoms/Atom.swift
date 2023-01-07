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
public func atom<T: Equatable>(_ value: T) -> Atom<T> {
    Atom(value)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.
public func atom<T: Equatable>(_ fn: @escaping () throws -> T) -> Atom<T> {
    Atom(get: fn)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.

public func atom<T: Equatable, E: Error>(_ fn: @escaping AtomCombineGet<T, E>) -> AsyncAtom<T> {
    AsyncAtom(get: fn)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.

public func atom<T: Equatable>(_ fn: @escaping AtomAsyncGet<T>) -> AsyncAtom<T> {
    AsyncAtom(get: fn)
}

public struct Atom<T: Equatable>: SyncAtomNode, Writeable {
    public typealias T = T
    public typealias E = Never
    
    public let key: String
    public let get: () throws -> T
    
    public init(key: String = "Atom-\(UUID())", _ value: T) {
        self.key = key
        self.get = { value }
    }
    
    public init(key: String = "Atom-\(UUID())", get: @escaping () throws -> T) {
        self.key = key
        self.get = get
    }
    
    public func compute() throws -> T {
        try get()
    }
}

public struct AsyncAtom<T: Equatable>: AsyncAtomNode, Writeable {
    public let key: String
    public var get: () async throws -> T
    
    public init<E: Error>(key: String = "AsyncAtom-\(UUID())", get: @escaping AtomCombineGet<T, E>) {
        self.key = key
        self.get = { try await get().async() }
    }
    
    public init(key: String = "AsyncAtom-\(UUID())", get: @escaping AtomAsyncGet<T>) {
        self.key = key
        self.get = { try await get() }
    }
    
    public func compute() async throws -> T {
        try await get()
    }
}
