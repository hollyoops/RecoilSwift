public struct Getter {
    private let contextKey: String?
    
    init(_ cotext: String? = nil) {
        self.contextKey = cotext
    }
    
    public func callAsFunction<T: RecoilSyncValue>(_ recoilValue: T) -> T.T {
        let storeRef = RecoilStore.shared
        
        guard let loadable = storeRef.safeGetLoadable(for: recoilValue) as? LoadBox<T.T> else {
            fatalError("Can not convert loadable to loadbox.")
        }
        
        if let host = contextKey {
            storeRef.makeConnect(key: host, upstream: recoilValue.key)
        }
        
        if loadable.status == .initiated {
          loadable.load()
        }
      
        return try! recoilValue.data(from: loadable) 
    }
    
    public func callAsFunction<T: RecoilAsyncValue>(_ recoilValue: T) -> T.T? {
        let storeRef = RecoilStore.shared
        
        guard let loadable = storeRef.safeGetLoadable(for: recoilValue) as? LoadBox<T.T> else {
            fatalError("Can not convert loadable to loadbox.")
        }
        
        if let host = contextKey {
            storeRef.makeConnect(key: host, upstream: recoilValue.key)
        }
        
        if loadable.status == .initiated {
          loadable.load()
        }
      
        return recoilValue.data(from: loadable)
    }
}

public struct Setter {
    private let contextKey: String?
    
    init(_ context: String? = nil) {
        self.contextKey = context
    }
    
    public func callAsFunction<T: RecoilState>(_ recoilValue: T, _ newValue: T.T) -> Void {
        let storeRef = RecoilStore.shared
        
        _ = storeRef.safeGetLoadable(for: recoilValue)
        
        recoilValue.update(with: newValue)
    }
    
    public func callAsFunction<T: RecoilAsyncState>(_ recoilValue: T, _ newValue: T.T) -> Void {
        let storeRef = RecoilStore.shared
        
        _ = storeRef.safeGetLoadable(for: recoilValue)
        
        recoilValue.update(with: newValue)
    }
}

public struct MutableContext {
    let get: Getter
    let set: Setter
}
