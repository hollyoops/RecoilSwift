import Combine

public typealias SelectorFamilyGet<P, T> = (P, StateGetter) throws -> T
public typealias SelectorFamilyCombineGet<P, T, E: Error> = (P, StateGetter) -> AnyPublisher<T, E>
public typealias SelectorFamilyAsyncGet<P, T> = (P, StateGetter) async throws -> T

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that is passed an object of named callbacks that returns the value of the selector
/// - Returns: A function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.
public func selectorFamily<P:Hashable, T: Equatable>(
    _ getBody: @escaping SelectorFamilyGet<P, T>,
    fileID: String = #fileID,
    line: Int = #line
) -> FamilyFunc<P, Selector<T>> {
    
    return { (param: P) -> ParametricRecoilValue<P, Selector<T>> in
        let keyName = sourceLocationKey(Selector<T>.self, fileName: fileID, line: line)
        let key = NodeKey(name: keyName) { hasher in
            hasher.combine(param)
        }
        let body = curry(getBody)(param)
        return ParametricRecoilValue(recoilValue: Selector(key: key, body: body), param: param)
    }
}

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter. and it evaluates the value for the derived state.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous selector with combine. Each unique parameter value will return the same memoized selector instance.

public func selectorFamily<P: Hashable, T: Equatable, E: Error>(
    _ getBody: @escaping SelectorFamilyCombineGet<P, T, E>,
    fileID: String = #fileID,
    line: Int = #line
) -> FamilyFunc<P, AsyncSelector<T>> {
    
    return { (param: P) -> ParametricRecoilValue<P, AsyncSelector<T>> in
        let keyName = sourceLocationKey(AsyncSelector<T>.self, fileName: fileID, line: line)
        let key = NodeKey(name: keyName) { hasher in
            hasher.combine(param)
        }
        return ParametricRecoilValue(
            recoilValue: AsyncSelector(key: key) { try await getBody(param, $0).async() },
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
    fileID: String = #fileID,
    line: Int = #line
) -> FamilyFunc<P, AsyncSelector<T>> {
    
    return { (param: P) -> ParametricRecoilValue<P, AsyncSelector<T>> in
        let keyName = sourceLocationKey(AsyncSelector<T>.self, fileName: fileID, line: line)
        let key = NodeKey(name: keyName) { hasher in
            hasher.combine(param)
        }
        let body = curry(getBody)(param)
        return ParametricRecoilValue(
            recoilValue: AsyncSelector(key: key, get: body),
            param: param
        )
    }
}
