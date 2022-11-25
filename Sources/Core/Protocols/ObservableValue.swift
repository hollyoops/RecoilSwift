public protocol RecoilCancelable {
  func cancel()
}

public protocol AnyValueChangeObservable {
    func observeValueChange(_ change: @escaping (Any) -> Void) -> Subscription
}
