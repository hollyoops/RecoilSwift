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

public typealias CombineGetAtomFunc<T: Equatable, E: Error> = () throws -> AnyPublisher<T, E>

public typealias AsyncGetAtomFunc<T: Equatable> = () async throws -> T

public struct Atom<T: Equatable>: SyncAtomNode {
    public typealias T = T
    public typealias E = Never
    
    public let key: String
    public let get: (Getter) throws -> T
    
    public init(key: String = "Atom-\(UUID())", _ value: T) {
        self.key = key
        self.get = { _ in value }
    }
}

extension Atom: Writeable {
    public func update(context: MutableContext, newValue: T) {
        guard let loadbox = context.loadable as? SyncLoadBox<T> else {
            return
        }
        
        loadbox.status = .solved(newValue)
    }
}

public struct AsyncAtom<T: Equatable>: AsyncAtomNode {
    public let key: String
    public var get: (Getter) async throws -> T
    
    public init<E: Error>(key: String = "AsyncAtom-\(UUID())", get: @escaping CombineGetAtomFunc<T, E>) {
        self.key = key
        self.get = { _ in try await get().async() }
    }
    
    public init(key: String = "AsyncAtom-\(UUID())", get: @escaping AsyncGetAtomFunc<T>) {
        self.key = key
        self.get = { _ in try await get() }
    }
}

extension AsyncAtom: Writeable {
    public func update(context: MutableContext, newValue: T) {
        guard let loadbox = context.loadable as? AsyncLoadBox<T> else {
            return
        }
        
        loadbox.status = .solved(newValue)
    }
}
