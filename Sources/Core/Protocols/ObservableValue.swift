public protocol RecoilCancelable {
  func cancel()
}

public protocol RecoilObservable {
    func observe(_ change: @escaping () -> Void) -> RecoilCancelable
}
