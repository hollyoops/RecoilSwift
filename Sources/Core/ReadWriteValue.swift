public struct Getter {
    private let hostKey: String?
    
    init(_ hostKey: String? = nil) {
        self.hostKey = hostKey
    }
    
    public func callAsFunction<T: RecoilValue>(_ recoilValue: T) -> T.DataType {
        let storeRef = Store.shared
        let loadable = storeRef.getLoadable(for: recoilValue)
        
        if let host = hostKey {
            storeRef.makeConnect(key: host, upstream: recoilValue.key)
        }
        
        return recoilValue.data(from: loadable)
    }
}

public struct Setter {
    private let hostKey: String?
    
    init(_ hostKey: String? = nil) {
        self.hostKey = hostKey
    }
    
    public func callAsFunction<T: RecoilState>(_ recoilValue: T, _ newValue: T.DataType) -> Void {
        let storeRef = Store.shared
        
        storeRef.registerIfNotExist(for: recoilValue)
        
        recoilValue.update(with: newValue)
    }
}
