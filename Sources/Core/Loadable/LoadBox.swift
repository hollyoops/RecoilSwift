public class LoadBox<T: Equatable, E: Error>: RecoilLoadable {
    private var shouldNotify = false
    public var data: T? {
        willSet {
            if data != newValue {
                shouldNotify = true
            }
        }
        didSet {
            if shouldNotify {
                valueDidChanged?()
                shouldNotify = false
            }
        }
    }
    public var error: E?
    public var status = LoadingStatus.initiated

    private let loader: LoaderProtocol
    private var valueDidChanged: (() -> Void)?

    var isAsynchronous: Bool {
        let isSync = loader is SynchronousLoader<T>
        return !isSync
    }

    init(loader: LoaderProtocol) {
        self.loader = loader
    }

    public func load() {
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

extension LoadBox: RecoilObservable {
    public func observe(_ change: @escaping () -> Void) -> RecoilCancelable {
        self.valueDidChanged = change

        let subscriber = Subscriber(change) { [weak self] _ in
            self?.valueDidChanged = nil
        }

        return subscriber
    }
}

extension LoadBox {
    private func fullFill(_ value: T) {
        self.error = nil
        self.data = value
        self.status = .solved
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

extension LoadBox: Equatable {
    public static func ==(lhs: LoadBox<T, E>, rhs: LoadBox<T, E>) -> Bool {
        lhs.status == rhs.status &&
        lhs.data == rhs.data
    }
}
