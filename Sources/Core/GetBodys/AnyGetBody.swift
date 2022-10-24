protocol Evaluator {
    associatedtype T: Equatable
    
    func eraseToAnyEvaluator() -> AnyGetBody<T>
}

extension Evaluator {
    func eraseToAnyEvaluator() -> AnyGetBody<T> {
        AnyGetBody(evaluator: self)
    }
}

public enum EvaluatorError: Error {
    case finishedWithoutValue
    case convertToAsyncFailed
    case convertToSyncFailed
    case convertValueFailed
}

protocol SyncEvaluator: Evaluator {
    func evaluate() throws -> T
}

protocol AsyncEvaluator: Evaluator {
    func evaluate() async throws -> T
}

public struct AnyGetBody<T: Equatable>: Evaluator {
    private let evaluator: any Evaluator
    
    public var isAsynchronous: Bool {
       evaluator is any AsyncEvaluator
    }
    
    init<P: Evaluator>(evaluator: P) where P.T == T {
        self.evaluator = evaluator
    }
    
    func evaluate() async throws -> T {
        guard let evaluator = evaluator as? (any AsyncEvaluator) else {
            throw EvaluatorError.convertToAsyncFailed
        }
        
        guard let val = try await evaluator.evaluate() as? T else {
            throw EvaluatorError.convertValueFailed
        }
        
        return val
    }
    
    func evaluate() -> Result<T, Error> {
        guard let evaluator = evaluator as? (any SyncEvaluator) else {
            return .failure(EvaluatorError.convertToSyncFailed)
        }
        
        do {
            guard let value = try evaluator.evaluate() as? T else {
                throw EvaluatorError.convertValueFailed
            }
            
            return .success(value)
        } catch {
            return .failure(error)
        }
    }
    
    func eraseToAnyEvaluator() -> AnyGetBody<T> {
        self
    }
}
