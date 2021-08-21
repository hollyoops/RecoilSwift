//MARK: - Atoms
public func atom<T>(_ value: T) -> Atom<T> {
    Atom(value)
}

public func atom<T>(_ fn: () -> T) -> Atom<T> {
    Atom(fn())
}

//MARK: - Selectors
public func selector<T>(_ getBody: @escaping GetBody<T>) -> ReadOnlySelector<T> {
    ReadOnlySelector(body: getBody)
}

@available(iOS 13.0, *)
public func selector<T, E: Error>(_ getBody: @escaping CombineGetBody<T, E>) -> ReadOnlyAsyncSelector<T> {
    let body: CombineGetBody<T, Error> = {
        try getBody($0)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    return ReadOnlyAsyncSelector(body: body)
}

public func selector<T>(get getBody: @escaping GetBody<T>, set setBody: @escaping SetBody<T>) -> Selector<T> {
    Selector(get: getBody, set: setBody)
}

//MARK: - Familys
public func selectorFamily<P, T>(get getBody: @escaping ParametricGetBody<P, T>) -> FamilyFunc<P, ReadOnlySelector<T>> {
    { (param: P) -> ParametricRecoilValue<P, ReadOnlySelector<T>> in
        let body = curry(getBody)(param)
        return ParametricRecoilValue(recoilValue: selector(body), param: param)
    }
}

@available(iOS 13.0, *)
public func selectorFamily<P, T, E: Error>(_ getBody: @escaping ParametricCombineGetBody<P, T, E>) -> FamilyFunc<P, ReadOnlyAsyncSelector<T>> {
    { (param: P) -> ParametricRecoilValue<P,  ReadOnlyAsyncSelector<T>> in
        let body: CombineGetBody<T, Error> = {
            try curry(getBody)(param)($0)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        
        return ParametricRecoilValue(recoilValue: selector(body), param: param)
    }
}
