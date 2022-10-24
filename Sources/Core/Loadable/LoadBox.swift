class LoadBox<T: Equatable, E: Error>: RecoilLoadable {
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
    public var error: Error?
    public var status = LoadingStatus.initiated
    
    private var task: Task<Void, Error>?
    private let evaluator: AnyGetBody<T>
    private var valueDidChanged: (() -> Void)?

    public var isAsynchronous: Bool {
        evaluator.isAsynchronous
    }
  
    public var isLoading: Bool {
        status == .loading
    }
    
    init(anyGetBody: AnyGetBody<T>) {
        self.evaluator = anyGetBody
    }
    
    public func load() {
        if status == .loading {
            self.cancel()
        }
        
        isAsynchronous ? loadAsync() : loadSync()
    }
    
    private func loadAsync () {
        self.status = .loading
        
        self.task = Task { @MainActor in
            do {
                let value = try await self.evaluator.evaluate()
                self.fullFill(value)
            } catch {
                self.reject(error)
            }
        }
    }
    
    private func loadSync() {
        self.status = .loading
        let ret = self.evaluator.evaluate()
        switch ret {
        case .success(let val): self.fullFill(val)
        case .failure(let err): self.reject(err)
        }
    }

    func cancel() {
        guard let t = self.task else { return }
        
        t.cancel()
        self.task = nil
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

    private func reject(_ error: Error) {
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
