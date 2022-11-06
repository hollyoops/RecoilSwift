public protocol RecoilWriteable {
    associatedtype T: Equatable
    
    func update(with value: T)
}

public typealias RecoilState = RecoilSyncValue & RecoilWriteable

public typealias RecoilAsyncState = RecoilAsyncValue & RecoilWriteable
