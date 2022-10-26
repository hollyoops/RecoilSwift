public enum LoadingStatus {
    case initiated
    case loading
    case solved
    case error
}

public protocol RecoilLoadable<Value>: RecoilObservable {
    associatedtype Value: Equatable
    
    var status: LoadingStatus { get }
    
    var isAsynchronous: Bool { get }
    
    var isLoading: Bool { get }
    
    func load()
    
    var data: Value? { get }
    
    var error: Error? { get }
}
