class LoadBox<T: Equatable>: RecoilLoadable {
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
    private let evaluator: any Evaluator<T>
    private var valueDidChanged: (() -> Void)?

    public var isAsynchronous: Bool {
       evaluator is any AsyncEvaluator
    }
  
    public var isLoading: Bool {
        status == .loading
    }
    
    init(anyGetBody: some Evaluator<T>) {
        self.evaluator = anyGetBody
    }
    
    public func load() {
        if status == .loading {
            self.cancel()
        }
        
        isAsynchronous ? loadAsync() : loadSync()
    }
    
    private func loadAsync () {
        @Sendable func evaluate() async throws -> T {
            if #available(iOS 16.0.0, *) {
                guard let evaluator = evaluator as? (any AsyncEvaluator<T>) else {
                    throw EvaluatorError.convertToAsyncFailed
                }
                
                return try await evaluator.evaluate()
            } else {
                guard let evaluator = evaluator as? (any AsyncEvaluator) else {
                    throw EvaluatorError.convertToAsyncFailed
                }
                
                guard let val = try await evaluator.evaluate() as? T else {
                    throw EvaluatorError.convertToAsyncFailed
                }
                
                return val
            }
        }
        
        self.status = .loading
        self.task = Task { @MainActor in
            do {
                let value = try await evaluate()
                self.fullFill(value)
            } catch {
                self.reject(error)
            }
        }
    }
    
    private func loadSync() {
        func evaluate() -> Result<T, Error> {
            guard let evaluator = evaluator as? (any SyncEvaluator) else {
                return .failure(EvaluatorError.convertToSyncFailed)
            }
            
            do {
                guard let value = try evaluator.evaluate() as? T else {
                    throw EvaluatorError.convertToAsyncFailed
                }
                
                return .success(value)
            } catch {
                return .failure(error)
            }
        }
        
        self.status = .loading
        let ret = evaluate()
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
    public func observe(_ change: @escaping () -> Void) -> Subscription {
        self.valueDidChanged = change

        return Subscription { [weak self] in
            self?.valueDidChanged = nil
        }
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
    public static func ==(lhs: LoadBox<T>, rhs: LoadBox<T>) -> Bool {
        lhs.status == rhs.status &&
        lhs.data == rhs.data
    }
}
