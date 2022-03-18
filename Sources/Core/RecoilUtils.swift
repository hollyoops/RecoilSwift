//MARK: - Atoms

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - value: The initial value of the atom
/// - Returns: A writeable RecoilState object.
public func atom<T: Equatable>(_ value: T) -> Atom<T> {
    Atom(value)
}

/// An atom represents state in Recoil. The ``atom()`` function returns a writeable ``RecoilState`` object.
/// - Parameters:
///  - fn: A closure that provide init value for the atom
/// - Returns: A writeable RecoilState object.
public func atom<T: Equatable>(_ fn: () -> T) -> Atom<T> {
    Atom(fn())
}

//MARK: - Selectors

/// A Selector represent a derived state in Recoil. If only a get function is provided, the selector is read-only and returns a ``Readonly Selector``
/// - Parameters:
///  - getBody: A synchronous function that evaluates the value for the derived state.
/// - Returns: A synchronous readonly selector.
public func selector<T: Equatable>(_ getBody: @escaping GetBody<T>) -> Selector<T> {
    Selector(body: getBody)
}

/// A Selector represent a derived state in Recoil. If only a get function is provided, the selector is read-only and returns a ``Readonly Selector``
/// - Parameters:
///  - getBody:  A asynchronous function that evaluates the value for the derived state. It return ``AnyPublisher`` object.
/// - Returns: A asynchronous readonly selector with combine.
@available(iOS 13.0, *)
public func selector<T: Equatable, E: Error>(_ getBody: @escaping CombineGetBody<T, E>) -> AsyncSelector<T, E> {
    AsyncSelector(get: getBody)
}

/// A Selector represent a derived state in Recoil. If only a get function is provided, the selector is read-only and returns a ``Readonly Selector``
/// - Parameters:
///  - getBody:  A async function that evaluates the value for the derived state.
/// - Returns: A asynchronous readonly selector with ``async/await``.
@available(iOS 15.0, *)
public func selector<T: Equatable>(_ getBody: @escaping AsyncGetBody<T>) -> AsyncSelector<T, Error> {
    AsyncSelector(get: getBody)
}

/// A Selector represent a derived state in Recoil. If the get and set function are provided, the selector is writeable
/// - Parameters:
///  - get: A synchronous function that evaluates the value for the derived state.
///  - set: A synchronous function that can store a value to Recoil object
/// - Returns: A asynchronous readonly selector with ``async/await``.
public func selector<T: Equatable>(get getBody: @escaping GetBody<T>, set setBody: @escaping SetBody<T>) -> MutableSelector<T> {
    MutableSelector(get: getBody, set: setBody)
}

//MARK: - Families

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that is passed an object of named callbacks that returns the value of the selector
/// - Returns: A function which can be called with user-defined parameters and returns a selector. Each unique parameter value will return the same memoized selector instance.
public func selectorFamily<P, T: Equatable>(
    _ getBody: @escaping ParametricGetBody<P, T>
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
@available(iOS 13.0, *)
public func selectorFamily<P, T: Equatable, E: Error>(
    _ getBody: @escaping ParametricCombineGetBody<P, T, E>
) -> FamilyFunc<P, AsyncSelector<T, E>> {
    
    return { (param: P) -> ParametricRecoilValue<P, AsyncSelector<T, E>> in
        let body = curry(getBody)(param)
        return ParametricRecoilValue(recoilValue: selector(body), param: param)
    }
}

/// A ``selectorFamily`` is a powerful pattern that is similar to a selector, but allows you to pass parameters
/// - Parameters:
///   - getBody: A function that can pass an user-defined parameter. and it evaluates the value for the derived state.
/// - Returns: A function which can be called with user-defined parameters and returns a asynchronous selector with ``async/await``. Each unique parameter value will return the same memoized selector instance.
@available(iOS 15.0, *)
public func selectorFamily<P, T: Equatable>(
    _ getBody: @escaping ParametricAsyncGetBody<P, T>
) -> FamilyFunc<P, AsyncSelector<T, Error>> {
    
    return { (param: P) -> ParametricRecoilValue<P, AsyncSelector<T, Error>> in
        let body = curry(getBody)(param)
        return ParametricRecoilValue(recoilValue: selector(body), param: param)
    }
}
