public enum LoadingStatus {
    case initiated
    case loading
    case solved
    case error
}

public protocol Loadable {
    var status: LoadingStatus { get }
    
    var isAsynchronous: Bool { get }
    
    var isLoading: Bool { get }
     
    func load()
  
    func getData<T>(of type: T.Type) -> T?
  
    func getError() -> Error?
}

public protocol RecoilLoadable: Loadable {
    associatedtype Data: Equatable
    
    associatedtype Failure: Error
    
    var data: Data? { get }
    
    var error: Failure? { get }
}

public extension RecoilLoadable {
    func getError() -> Error? {
        error
    }
  
    func getData<T>(of type: T.Type) -> T? {
        data as? T
    }
}
