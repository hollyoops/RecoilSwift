import Foundation
import Combine

@available(iOS 13.0, *)
public typealias CombineAtomBody<T: Equatable, E: Error> = () throws -> AnyPublisher<T, E>

@available(iOS 15.0, *)
public typealias AsyncAtomBody<T: Equatable> = () async throws -> T

/// Atoms are units of state. They're updatable and subscribable: when an atom is updated, each subscribed component is re-rendered with the new value.
///
/// They can be created at runtime, too. Atoms can be used in place of local component state. If the same atom is used  from multiple components, all those components share their state.
///
/// ```swift
/// let allBookState = atom { [Book]() }
/// ```
/// You can retrive value with ``Recoil hooks``,
/// eg: ``useRecoilState(allBookState)``

public final class Atom<T: Equatable> {
  public let key: String
  private var get: () throws -> T
  
  public init(key: String = "Atom-\(UUID())", _ value: T) {
    self.key = key
    get = { value }
  }
}

extension Atom: RecoilValue {
  public func data(from loadable: Loadable) throws -> T {
    let loadBox = loadable as! LoadBox<T, Never>
    
    if loadBox.status == .initiated {
      loadBox.load()
    }
  
    guard let data = loadBox.data else {
      throw loadBox.error ?? RecoilError.unknown
    }
    
    return data
  }
  
  public func makeLoadable() -> LoadBox<T, Never> {
    let loader = SynchronousLoader(get)
    return LoadBox(loader: loader)
  }
}

extension Atom: RecoilWriteable {
  public func update(with value: T) {
    self.get = { value }
    Store.shared.update(recoilValue: self, newValue: value)
  }
}

@available(iOS 13.0, *)
struct AtomCombineCallback<T: Equatable, E: Error>: AsyncGet {
    func toLoader(for key: String) -> LoaderProtocol {
        let getFn = self.get
        return CombineLoader { try getFn() }
    }
    
    public let get: CombineAtomBody<T, E>
}

@available(iOS 15.0, *)
struct AtomAsyncCallback<T: Equatable>: AsyncGet {
    public let get: AsyncAtomBody<T>
    
    func toLoader(for key: String) -> LoaderProtocol {
        let getFn = self.get
        return AsynchronousLoader { try await getFn() }
    }
}

public struct AsyncAtom<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
  public let key: String
  public let get: AsyncGet
  
  public init(key: String = "AsyncAtom-\(UUID())", get: @escaping CombineAtomBody<T, E>) {
      self.key = key
      self.get = AtomCombineCallback(get: get)
  }
  
  @available(iOS 15.0, *)
  public init(key: String = "AsyncAtom-\(UUID())", get: @escaping AsyncAtomBody<T>) {
      self.key = key
      self.get = AtomAsyncCallback(get: get)
  }
}

extension AsyncAtom: RecoilWriteable {
  public func update(with value: T?) {
    Store.shared.update(recoilValue: self, newValue: value)
  }
}
