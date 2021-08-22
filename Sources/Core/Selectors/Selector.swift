import Foundation

public typealias ReadOnlyContext = GetterFunction
public typealias MutableContext = (
    get: GetterFunction,
    set: SetterFunction
)

public typealias GetBody<T> = (GetterFunction) throws -> T
public typealias SetBody<T> = (MutableContext, T) -> Void

public protocol ISyncSelector: ISelector {}
extension ISyncSelector {
    public var wrappedData: State {
        executor.loadable.data!
    }
}

public struct ReadOnlySelector<State: Equatable>: ISyncSelector {
    public let executor: SelectorExecutor<State>
    
    init(key: String = "R-Sel-\(UUID())", body: @escaping GetBody<State>) {
        self.executor = SelectorExecutor(key: key, getBody: body)
    }
}

public struct Selector<State: Equatable>: ISyncSelector, IRecoilState {
    public let setBody: SetBody<State>
    public let executor: SelectorExecutor<State>
    
    public init(key: String = "WR-Sel-\(UUID())", get: @escaping GetBody<State>, set: @escaping SetBody<State>) {
        self.setBody = set
        self.executor = SelectorExecutor(key: key, getBody: get)
    }
}

// MARK: - IRecoilState implement
extension Selector {
    public func update(_ newValue: State) {
        setBody(makeMutableContext(), newValue)
    }
    
    public func callAsFunction(value: State) -> Void {
        update(value)
    }
    
    private func makeMutableContext() -> MutableContext {
        MutableContext(get: GetterFunction(), set: SetterFunction())
    }
}
