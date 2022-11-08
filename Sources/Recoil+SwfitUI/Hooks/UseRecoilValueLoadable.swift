import Hooks
import Foundation

/// A loadable object that contains loading informations
public struct LoadableContent<DataType> {
    public let key: String
    private let store: Store
    
    init<T: RecoilValue>(node: T, store: Store) {
        self.store = store
        self.key = node.key
        self.initNode(node)
    }

    public var isAsynchronous: Bool {
        guard let loadable = store.getLoadable(for: key) else {
            return false
        }
        
        return loadable.isAsynchronous
    }
    
    public var data: DataType? {
        store.getData(for: key, dataType: DataType.self)
    }
    
    public var isLoading: Bool {
        store.getLoadingStatus(for: key)
    }
    
    public var loadingStatus: LoadingStatus {
        guard let loadable = store.getLoadable(for: key) else {
            return .initiated
        }
        
        return  loadable.status
    }
    
    public var hasError: Bool {
        !errors.isEmpty
    }
    
    public var errors: [Error] {
        store.getErrors(for: key)
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
        store.getLoadable(for: key)?.load()
    }
    
    private func initNode<T: RecoilValue>(_ recoilValue: T) {
        guard
            loadingStatus == .initiated,
            let loadable = store.safeGetLoadable(for: recoilValue) as? LoadBox<T.T> else {
            return
        }
        loadable.load()
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
        let ctx = getStoredContext(coordinator: coordinator)
        return ctx.useRecoilValueLoadable(initialValue)
    }
}
