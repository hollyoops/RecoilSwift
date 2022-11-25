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

public final class Atom<T: Equatable>: SyncAtomNode {
  public typealias T = T
  public typealias E = Never
  
  public let key: String
  public private(set) var get: any Evaluator<T>
  
  public init(key: String = "Atom-\(UUID())", _ value: T) {
    self.key = key
    self.get = SyncGetBody({ value })
  }
}

extension Atom: Writeable {
  public func update(with value: T) {
    self.get = SyncGetBody({ value })
    RecoilStore.shared.update(node: self, newValue: value)
  }
}

public struct AsyncAtom<T: Equatable>: AsyncAtomNode {
  public let key: String
  public let get: any Evaluator<T>
  
  public init<E: Error>(key: String = "AsyncAtom-\(UUID())", get: @escaping CombineGetBodyFunc<T, E>) {
      self.key = key
      self.get = CombineGetBody(get)
  }
  
  public init(key: String = "AsyncAtom-\(UUID())", get: @escaping AsyncGetBodyFunc<T>) {
      self.key = key
      self.get = AsyncGetBody(get)
  }
}

extension AsyncAtom: Writeable {
  public func update(with value: T) {
    RecoilStore.shared.update(node: self, newValue: value)
  }
}
