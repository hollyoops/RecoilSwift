class LoadBox<T: Equatable>: RecoilLoadable {    
    private var shouldNotify = false
    public var data: T? {        
        guard case let .solved(value) = status else {
            return nil
        }

        return value
    }
    
    public var error: Error? {
        guard case let .error(err) = status else {
            return nil
        }

        return err
    }
    
    public var status = NodeStatus<T>.initiated {
        willSet {
            if status != newValue {
                shouldNotify = true
            }
        }
        didSet {
            if shouldNotify {
                valueDidChanged?(status)
                shouldNotify = false
            }
        }
    }
    
    private var task: Task<Void, Error>?
    private let evaluator: any Evaluator<T>
    private var valueDidChanged: ((NodeStatus<T>) -> Void)?

    public var isAsynchronous: Bool {
       evaluator is any AsyncEvaluator
    }
    
    init(anyGetBody: some Evaluator<T>) {
        self.evaluator = anyGetBody
    }
    
    public func load() {
        if isLoading {
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
        valueDidChanged?(status)
    }
}

extension LoadBox {
    public func observeStatusChange(_ change: @escaping (NodeStatus<T>) -> Void) -> Subscription {
        self.valueDidChanged = change

        return Subscription { [weak self] in
            self?.valueDidChanged = nil
        }
    }
}

extension LoadBox {
    private func fullFill(_ value: T) {
        self.status = .solved(value)
    }

    private func reject(_ error: Error) {
        self.status = .error(error)
        
        // TODO: Compare error only trigger when error changed
        valueDidChanged?(status)
    }
}
