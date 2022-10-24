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

public final class Atom<T: Equatable>: RecoilSyncReadable {
  public typealias T = T
  public typealias E = Never
  public typealias DataType = T
    
  public let key: String
  public private(set) var get: AnyGetBody<T>
  
  public init(key: String = "Atom-\(UUID())", _ value: T) {
    self.key = key
    self.get = SyncGetBody({ value }).eraseToAnyEvaluator()
  }
}

extension Atom: RecoilWriteable {
  public func update(with value: T) {
    self.get = SyncGetBody({ value }).eraseToAnyEvaluator()
    Store.shared.update(recoilValue: self, newValue: value)
  }
}

public struct AsyncAtom<T: Equatable, E: Error>: RecoilAsyncReadable {
  public let key: String
  public let get: AnyGetBody<T>
  
  public init(key: String = "AsyncAtom-\(UUID())", get: @escaping CombineGetBodyFunc<T, E>) {
      self.key = key
      self.get = CombineGetBody(get).eraseToAnyEvaluator()
  }
  
  @available(iOS 13.0, *)
  public init(key: String = "AsyncAtom-\(UUID())", get: @escaping AsyncGetBodyFunc<T>) {
      self.key = key
      self.get = AsyncGetBody(get).eraseToAnyEvaluator()
  }
}

extension AsyncAtom: RecoilWriteable {
  public func update(with value: T?) {
    Store.shared.update(recoilValue: self, newValue: value)
  }
}
