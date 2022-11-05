import Hooks
import Foundation

/// A loadable object that contains loading informations
public struct LoadableContent<DataType> {
  public let key: String
  
  public var isAsynchronous: Bool {
    guard let loadable = RecoilStore.shared.getLoadable(for: key) else {
      return false
    }
    
    return loadable.isAsynchronous
  }
  
  public var data: DataType? {
    RecoilStore.shared.getData(for: key, dataType: DataType.self)
  }
  
  public var isLoading: Bool {
    RecoilStore.shared.getLoadingStatus(for: key)
  }
  
  public var hasError: Bool {
    !errors.isEmpty
  }

  public var errors: [Error] {
    RecoilStore.shared.getErrors(for: key)
  }
  
  public func containError<T: Error & Equatable>(of err: T) -> Bool {
    errors.contains { e in
      if let concreteError = e as? T {
        return concreteError == err
      }
      return false
    }
  }
  
  public func load() {
    RecoilStore.shared.getLoadable(for: key)?.load()
  }
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector wrapper which with user-defined parameters
/// - Returns: return a loadable object that contains loading informations
public func useRecoilValueLoadable<P: Equatable, Return: RecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> LoadableContent<Return.T> {
  let hook = RecoilLoadableValueHook(initialValue: value.recoilValue,
                                     updateStrategy: .preserved(by: value.param))
  
  return useHook(hook)
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector
/// - Returns: return a loadable object that contains loading informations
public func useRecoilValueLoadable<Value: RecoilValue>(_ value: Value) -> LoadableContent<Value.T> {
  useHook(RecoilLoadableValueHook(initialValue: value))
}

private struct RecoilLoadableValueHook<T: RecoilValue>: RecoilHook {
  var initialValue: T
  var updateStrategy: HookUpdateStrategy?
  
  func value(coordinator: Coordinator) -> LoadableContent<T.T> {
    LoadableContent<T.T>(key: coordinator.state.value.key)
  }
}
