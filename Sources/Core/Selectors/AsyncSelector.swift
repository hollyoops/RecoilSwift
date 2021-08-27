import Foundation
#if canImport(Combine)
import Combine
#endif

@available(iOS 13.0, *)
public typealias CombineGetBody<T: Equatable, E: Error> = (GetterFunction) throws -> AnyPublisher<T, E>

public protocol IAsyncSelector: ISelector {}

extension IAsyncSelector {
    public var wrappedData: State? {
        loadable.data
    }
}

public struct ReadOnlyAsyncSelector<State: Equatable>: IAsyncSelector {
    public let executor: SelectorExecutor<State>
    public typealias DefaultValue = State?

    @available(iOS 13.0, *)
    public init(key: String = "R-AsyncSel-\(UUID())", body: @escaping CombineGetBody<State, Error>) {
        self.executor = SelectorExecutor(key: key, getBody: body)
    }
}

public struct AsyncSelector<State: Equatable>: IAsyncSelector, IRecoilState {
    public let setBody: SetBody<DataType>
    public let executor: SelectorExecutor<State>

    @available(iOS 13.0, *)
    public init(key: String = "WR-AsyncSel-\(UUID())",
                get: @escaping CombineGetBody<State, Error>,
                set: @escaping SetBody<DataType>) {
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
