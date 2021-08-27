public protocol ISelector: IRecoilValue {
    associatedtype State: Equatable
    
    associatedtype Failure: Error

    var executor: SelectorExecutor<State, Failure> { get }
}

extension ISelector {
    public func mount() {
        executor.initNode()
    }
    
    public var loadable: LoadableContainer<State, Failure> {
        executor.loadable
    }
    
    public func observe(_ change: @escaping () -> Void) -> ICancelable {
        executor.observe(change)
    }
    
    public var key: String {
        executor.key
    }
}
