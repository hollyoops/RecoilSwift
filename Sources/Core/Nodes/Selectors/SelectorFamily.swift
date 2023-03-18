import Combine

public typealias SelectorFamily<P: Hashable, T: Equatable> = (P) -> RecoilParamNode<P, Selector<T>>

public typealias AsyncSelectorFamily<P: Hashable, T: Equatable> = (P) -> RecoilParamNode<P, AsyncSelector<T>>

public typealias SelectorFamilyGet<P, T> = (P, StateGetter) throws -> T

public typealias SelectorFamilyCombineGet<P, T, E: Error> = (P, StateGetter) -> AnyPublisher<T, E>

public typealias SelectorFamilyAsyncGet<P, T> = (P, StateGetter) async throws -> T

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that is passed an object of named callbacks that returns the value of the selector
/// - Returns: A function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.
public func selectorFamily<P: Hashable, T: Equatable>(
    _ getBody: @escaping SelectorFamilyGet<P, T>,
    funcName: String = #function,
    fileID: String = #fileID,
    line: Int = #line
) -> SelectorFamily<P, T> {
    
    return { (param: P) -> RecoilParamNode<P, Selector<T>> in
        let pos = SourcePosition(funcName: funcName, fileName: fileID, line: line)
        let key = NodeKey(position: pos) { hasher in
            hasher.combine(param)
        }
        let body = curry(getBody)(param)
        return RecoilParamNode(node: Selector(key: key, body: body), param: param)
    }
}

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter. and it evaluates the value for the derived state.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous selector with combine. Each unique parameter value will return the same memoized selector instance.

public func selectorFamily<P: Hashable, T: Equatable, E: Error>(
    _ getBody: @escaping SelectorFamilyCombineGet<P, T, E>,
    funcName: String = #function,
    fileID: String = #fileID,
    line: Int = #line
) -> AsyncSelectorFamily<P, T> {
    
    return { (param: P) -> RecoilParamNode<P, AsyncSelector<T>> in
        let pos = SourcePosition(funcName: funcName, fileName: fileID, line: line)
        let key = NodeKey(position: pos) { hasher in
            hasher.combine(param)
        }
        return RecoilParamNode(
            node: AsyncSelector(key: key) { try await getBody(param, $0).async() },
            param: param
        )
    }
}

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter. and it evaluates the value for the derived state.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous selector with ``async/await``. Each unique parameter value will return the same memoized selector instance.

public func selectorFamily<P: Hashable, T: Equatable>(
    _ getBody: @escaping SelectorFamilyAsyncGet<P, T>,
    funcName: String = #function,
    fileID: String = #fileID,
    line: Int = #line
) -> AsyncSelectorFamily<P, T> {
    
    return { (param: P) -> RecoilParamNode<P, AsyncSelector<T>> in
        let pos = SourcePosition(funcName: funcName, fileName: fileID, line: line)
        let key = NodeKey(position: pos) { hasher in
            hasher.combine(param)
        }
        let body = curry(getBody)(param)
        return RecoilParamNode(
            node: AsyncSelector(key: key, get: body),
            param: param
        )
    }
}
