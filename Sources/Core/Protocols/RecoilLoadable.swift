public enum LoadingStatus {
    case initiated
    case loading
    case solved
    case error
}

public protocol RecoilLoadable: RecoilObservable {
    associatedtype Value: Equatable
    
    associatedtype Failure: Error
    
    var status: LoadingStatus { get }
    
    var isAsynchronous: Bool { get }
    
    var isLoading: Bool { get }
    
    func load()
    
    var data: Value? { get }
    
    var error: Failure? { get }
}
