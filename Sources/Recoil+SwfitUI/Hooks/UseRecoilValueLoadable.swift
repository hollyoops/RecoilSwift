import Hooks
import Foundation

/// A loadable object that contains loading informations
public struct LoadableContent<DataType: Equatable> {
    public let key: NodeKey
    private let store: Store
    
    init<T: RecoilNode>(node: T, store: Store) {
        self.store = store
        self.key = node.key
        self.initNode(node)
    }

    public var isAsynchronous: Bool {
        guard let loadable = store.getLoadable(for: key) else {
            return false
        }
        
        return loadable is AsyncLoadBox<DataType>
    }
    
    public var data: DataType? {
        store.getData(for: key, dataType: DataType.self)
    }
    
    public var isLoading: Bool {
        store.getLoadingStatus(for: key)
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
    
    public func refresh() {
        NodeAccessor(store: store).refresh(for: key)
    }
    
    private func initNode<T: RecoilNode>(_ recoilValue: T) {
        NodeAccessor(store: store).loadNodeIfNeeded(recoilValue)
    }
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector wrapper which with user-defined parameters
/// - Returns: return a loadable object that contains loading informations
@MainActor
public func useRecoilValueLoadable<P: Equatable, Return: RecoilNode>(
    _ value: ParametricRecoilValue<P, Return>
) -> LoadableContent<Return.T> {
    let hook = RecoilLoadableValueHook(node: value.recoilValue,
                                       updateStrategy: .preserved(by: value.param))
    
    return useHook(hook)
}

/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector
/// - Returns: return a loadable object that contains loading informations
@MainActor
public func useRecoilValueLoadable<Value: RecoilNode>(_ value: Value) -> LoadableContent<Value.T> {
    useHook(RecoilLoadableValueHook(node: value))
}

private struct RecoilLoadableValueHook<Node: RecoilNode>: RecoilHook {
    let initialValue: Node
    let updateStrategy: HookUpdateStrategy?
    
    init(node: Node, updateStrategy: HookUpdateStrategy? = nil) {
        self.initialValue = node
        self.updateStrategy = updateStrategy
    }
    
    @MainActor
    func value(coordinator: Coordinator) -> LoadableContent<Node.T> {
        let ctx = getStoredContext(coordinator: coordinator)
        return ctx.useRecoilValueLoadable(initialValue)
    }
}
