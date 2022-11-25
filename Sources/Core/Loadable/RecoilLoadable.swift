public protocol BaseLoadable: AnyValueChangeObservable {
    var isAsynchronous: Bool { get }
    
    var isLoading: Bool { get }
    
    var isInitiated: Bool { get }
    
    var anyData: Any? { get }
    
    var error: Error? { get }
    
    func load()
}

public protocol RecoilLoadable<Value>: BaseLoadable {
    associatedtype Value: Equatable
    
    var status: NodeStatus<Value> { get }
    
    var data: Value? { get }
    
    func observeStatusChange(_ change: @escaping (NodeStatus<Value>) -> Void) -> Subscription
}

extension RecoilLoadable {
    public var isLoading: Bool {
        if case .loading = status { return true }
        return false
    }
    
    public var isInitiated: Bool {
        if case .initiated = status { return true }
        return false
    }
    
    public var anyData: Any? { data }
    
    func observeValueChange(_ change: @escaping (Any) -> Void) -> Subscription {
        observeStatusChange { change($0) }
    }
}
