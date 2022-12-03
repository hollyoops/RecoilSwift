import Combine

public typealias SelectorFamilyGet<P, T> = (P, Getter) throws -> T
public typealias SelectorFamilyCombineGet<P, T, E: Error> = (P, Getter) -> AnyPublisher<T, E>
public typealias SelectorFamilyAsyncGet<P, T> = (P, Getter) async throws -> T

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that is passed an object of named callbacks that returns the value of the selector
/// - Returns: A function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.
public func selectorFamily<P, T: Equatable>(
    _ getBody: @escaping SelectorFamilyGet<P, T>
) -> FamilyFunc<P, Selector<T>> {
    
    return { (param: P) -> ParametricRecoilValue<P, Selector<T>> in
        let body = curry(getBody)(param)
        return ParametricRecoilValue(recoilValue: selector(body), param: param)
    }
}

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter. and it evaluates the value for the derived state.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous selector with combine. Each unique parameter value will return the same memoized selector instance.

public func selectorFamily<P, T: Equatable, E: Error>(
    _ getBody: @escaping SelectorFamilyCombineGet<P, T, E>
) -> FamilyFunc<P, AsyncSelector<T>> {
    
    return { (param: P) -> ParametricRecoilValue<P, AsyncSelector<T>> in
        return ParametricRecoilValue(
            recoilValue: selector { try await getBody(param, $0).async() },
            param: param
        )
    }
}

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter. and it evaluates the value for the derived state.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous selector with ``async/await``. Each unique parameter value will return the same memoized selector instance.

public func selectorFamily<P, T: Equatable>(
    _ getBody: @escaping SelectorFamilyAsyncGet<P, T>
) -> FamilyFunc<P, AsyncSelector<T>> {
    
    return { (param: P) -> ParametricRecoilValue<P, AsyncSelector<T>> in
        let body = curry(getBody)(param)
        return ParametricRecoilValue(
            recoilValue: selector(body),
            param: param
        )
    }
}
