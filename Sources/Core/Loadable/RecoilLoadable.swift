public protocol BaseLoadable: AnyValueChangeObservable {
    var isLoading: Bool { get }

    var isInvalid: Bool { get }

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
        status.isLoading
    }

    public var isInvalid: Bool {
        status.isInvalid
    }

    public var data: Value? {
        status.data
    }

    public var error: Error? {
        status.error
    }
    
    public var anyData: Any? { data }
    
    func observeValueChange(_ change: @escaping (Any) -> Void) -> Subscription {
        observeStatusChange { change($0) }
    }
}
