public protocol ISelector: IRecoilValue {
    associatedtype State: Equatable

    var executor: SelectorExecutor<State> { get }
}

extension ISelector {
    public func initNode() {
        executor.initNode()
    }
    
    public var loadable: LoadableContainer<State> {
        executor.loadable
    }
    
    public func observe(_ change: @escaping () -> Void) -> ICancelable {
        executor.observe(change)
    }
    
    public var key: String {
        executor.key
    }
}
