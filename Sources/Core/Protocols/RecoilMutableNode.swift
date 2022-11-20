public protocol Writeable {
    associatedtype T: Equatable
    
    func update(with value: T)
}

public typealias RecoilMutableNode = RecoilSyncNode & Writeable

public typealias RecoilAsyncMutableNode = RecoilAsyncNode & Writeable
