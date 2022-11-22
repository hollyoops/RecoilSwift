import Foundation

public enum LoadingStatus<T: Equatable>: Equatable {
    case initiated
    case loading
    case solved(T)
    case error(Error)
    
    public static func == (lhs: LoadingStatus<T>, rhs: LoadingStatus<T>) -> Bool {
        switch (lhs, rhs) {
        case (.initiated, .initiated):
            return true
        case (.loading, .loading):
            return true
        case let (.solved(value1), .solved(value2)):
            return value1 == value2
        case let (.error(error1), .error(error2)):
            let nsError1 = error1 as NSError
            let nsError2 = error2 as NSError
            return nsError1.domain == nsError2.domain && nsError1.code == nsError2.code
        default:
            return false
        }
    }
}

public protocol RecoilLoadable<Value>: RecoilObservable {
    associatedtype Value: Equatable
    
    var status: LoadingStatus<Value> { get }
    
    var isAsynchronous: Bool { get }
    
    var isLoading: Bool { get }
    
    func load()
    
    var data: Value? { get }
    
    var error: Error? { get }
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
}
