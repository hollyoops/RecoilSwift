public protocol ICancelable {
  func cancel()
}

public protocol IObservableValue {
    func observe(_ change: @escaping () -> Void) -> ICancelable
}
