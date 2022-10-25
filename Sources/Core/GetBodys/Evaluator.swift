public protocol Evaluator<T> {
    associatedtype T: Equatable
}

public enum EvaluatorError: Error {
    case finishedWithoutValue
    case convertToAsyncFailed
    case convertToSyncFailed
}

public protocol SyncEvaluator<T>: Evaluator {
    func evaluate() throws -> T
}

public protocol AsyncEvaluator<T>: Evaluator {
    func evaluate() async throws -> T
}
