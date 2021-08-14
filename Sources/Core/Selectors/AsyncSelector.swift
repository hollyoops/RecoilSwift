import Foundation
#if canImport(Combine)
import Combine
#endif

@available(iOS 13.0, *)
public typealias AsyncGetBody<T: Equatable, E: Error> = (GetterFunction) throws -> AnyPublisher<T, E>

public protocol IAysncSelector: ISelector where WrappedValue == State? { }
extension IAysncSelector {
    public var wrappedValue: WrappedValue {
        executor.loadable.data
    }
}

public struct ReadOnlyAsyncSelector<State: Equatable>: IAysncSelector {
    public let executor: SelectorExecutor<State>
    public typealias DefaultValue = State?
    
    @available(iOS 13.0, *)
    public init(key: String = "R-AsyncSel-\(UUID())", body: @escaping AsyncGetBody<State, Error>) {
        self.executor = SelectorExecutor(key: key, getBody: body)
    }
}

public struct AsyncSelector<State: Equatable>: IAysncSelector, IRecoilState {
    public let setBody: SetBody<WrappedValue>
    public let executor: SelectorExecutor<State>

    @available(iOS 13.0, *)
    public init(key: String = "WR-AsyncSel-\(UUID())",
         get: @escaping AsyncGetBody<State, Error>,
         set: @escaping SetBody<WrappedValue>) {
        self.setBody = set
        self.executor = SelectorExecutor(key: key, getBody: get)
    }
}

// MARK: - IRecoilState implement
extension AsyncSelector {
    public func update(_ newValue: State?) {
        setBody(makeMutableContext(), newValue)
    }
    
    public func callAsFunction(value: State?) -> Void {
        update(value)
    }
    
    private func makeMutableContext() -> MutableContext {
        MutableContext(get: GetterFunction(), set: SetterFunction())
    }
}
