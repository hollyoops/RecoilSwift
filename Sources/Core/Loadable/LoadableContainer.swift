public class LoadableContainer<T: Equatable, E: Error>: Loadable {
    public var data: T?
    public var error: E?
    public var status: LoadingStatus = .solved

    private let loader: LoaderProtocol
    private var valueDidChanged: (() -> Void)?

    var isAsynchronous: Bool {
        let isSync = loader is SynchronousLoader<T>
        return !isSync
    }

    init(value: T) {
        self.loader = SynchronousLoader { value }
        fullFill(value)
    }

    init(synchronous body: @escaping SynchronousLoaderBody<T>) {
        self.loader = SynchronousLoader(body)
    }

    @available(iOS 13, *)
    init(combine body: @escaping CombineLoaderBody<T, E>) {
        self.loader = CombineLoader(body)
    }

    func compute() {
        if status == .loading {
            self.loader.cancel()
        }

        self.status = .loading
        self.loader
        .toPromise()
        .then { [weak self] in self?.fullFill($0) }
        .catch { [weak self] in self?.reject($0) }

        self.loader.run()
    }

    func cancel() {
        self.loader.cancel()
        valueDidChanged?()
    }
}

extension LoadableContainer: IObservableValue {
    public func observe(_ change: @escaping () -> Void) -> ICancelable {
        self.valueDidChanged = change

        let subscriber = Subscriber(change) { [weak self] _ in
            self?.valueDidChanged = nil
        }

        return subscriber
    }
}

extension LoadableContainer {
    private func fullFill(_ value: T) {
        let isValueChanged = value != data

        self.error = nil
        self.data = value
        self.status = .solved

        if (isValueChanged) {
            valueDidChanged?()
        }
    }

    private func reject(_ error: E) {
        self.error = error
        self.status = .error

        if isAsynchronous {
            self.data = nil
        }
        // TODO: Compare error only trigger when error changed
        valueDidChanged?()
    }
}

extension LoadableContainer: Equatable {
    public static func ==(lhs: LoadableContainer<T, E>, rhs: LoadableContainer<T, E>) -> Bool {
        lhs.status == rhs.status &&
        lhs.data == rhs.data
    }
}
