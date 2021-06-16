public func atom<T>(_ value: T) -> Atom<T> {
    Atom(value)
}

public func selector<T>(_ getBody: @escaping GetBody<T>) -> ReadOnlySelector<T> {
    ReadOnlySelector(body: getBody)
}

@available(iOS 13.0, *)
public func selector<T>(_ getBody: @escaping AsyncGetBody<T, Error>) -> ReadOnlyAsyncSelector<T> {
    ReadOnlyAsyncSelector(body: getBody)
}

public func selector<T>(get getBody: @escaping GetBody<T>, set setBody: @escaping SetBody<T>) -> Selector<T> {
    Selector(get: getBody, set: setBody)
}
