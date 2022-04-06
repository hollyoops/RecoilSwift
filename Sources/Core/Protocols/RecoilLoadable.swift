public enum LoadingStatus {
    case initiated
    case loading
    case solved
    case error
}

public protocol Loadable {
    var status: LoadingStatus { get }
    
    func load()
}

public extension Loadable {
    var isLoading: Bool {
        status == .loading
    }
}

public protocol RecoilLoadable: Loadable {
    associatedtype Data: Equatable
    
    associatedtype Failure: Error
    
    var data: Data? { get }
    
    var error: Failure? { get }
}
