import Hooks
import Foundation

/// A loadable object that contains loading informations
public struct LoadableContent<DataType, Failure> {
  let key: String
  public let data: DataType?
  public let error: Failure?
  
  public var isAsynchronous: Bool {
    guard let loadable = Store.shared.getLoadable(key: key) else {
      return false
    }
    
    return loadable.isAsynchronous
  }
  
  public var isLoading: Bool {
    Store.shared.getLoadingStatus(for: key)
  }
  
  public var hasError: Bool {
    !errors.isEmpty
  }

  public var errors: [Error] {
    return Store.shared.getErrors(for: key)
  }
  
  public func load() {
    Store.shared.getLoadable(key: key)?.load()
  }
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector wrapper which with user-defined parameters
/// - Returns: return a loadable object that contains loading informations
public func useRecoilValueLoadable<P: Equatable, Return: RecoilValue>(_ value: ParametricRecoilValue<P, Return>) -> LoadableContent<Return.LoadableType.Data, Return.LoadableType.Failure> {
  let hook = RecoilLoadableValueHook(initialValue: value.recoilValue,
                                     updateStrategy: .preserved(by: value.param))
  
  return useHook(hook)
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector
/// - Returns: return a loadable object that contains loading informations
public func useRecoilValueLoadable<Value: RecoilValue>(_ value: Value) -> LoadableContent<Value.LoadableType.Data, Value.LoadableType.Failure> {
  useHook(RecoilLoadableValueHook(initialValue: value))
}

private struct RecoilLoadableValueHook<T: RecoilValue>: RecoilHook {
  var initialValue: T
  var updateStrategy: HookUpdateStrategy?
  
  func value(coordinator: Coordinator) -> LoadableContent<T.LoadableType.Data, T.LoadableType.Failure> {
    let value = coordinator.state.value
    let data = Store.shared.getData(for: value)
    let error = Store.shared.getError(for: value)
    
    return LoadableContent(key: value.key, data: data, error: error)
  }
}
