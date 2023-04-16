#if canImport(Hooks)

import Hooks
import Foundation


/// A hook is intended to be used for reading the value of asynchronous selectors. eg: You can get the ``loading``, ``error`` status with this hooks
/// - Parameters:
///   - value: A selector wrapper which with user-defined parameters
/// - Returns: return a loadable object that contains loading informations
@MainActor
public func useRecoilValueLoadable<P: Equatable, Return: RecoilNode>(
    _ value: RecoilParamNode<P, Return>
) -> LoadableContent<Return.T> {
    let hook = RecoilLoadableValueHook(node: value.node,
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
        let recoil = getStoredContext(coordinator: coordinator)
        return recoil.useLoadable(initialValue)
    }
}

#endif
