import Foundation
public protocol IIdentifiableValue {
    var key: String { get }
}

public enum LoadingStatus {
    case loading
    case solved
    case error
}

public protocol Loadable {
    associatedtype Data: Equatable
    
    associatedtype Failure: Error
    
    var status: LoadingStatus { get }
    
    var data: Data? { get }
    
    var error: Failure? { get }
}

public extension Loadable {
    var isLoading: Bool {
        status == .loading
    }
}

public protocol IRecoilValue: IObservableValue, IIdentifiableValue {
    associatedtype DataType: Equatable
    
    associatedtype LoadableType: Loadable
    
    func mount()
    
    var loadable: LoadableType { get }
    
    var wrappedData: DataType { get }
}

public protocol IRecoilState: IRecoilValue {
    func update(_ newValue: DataType)
}
