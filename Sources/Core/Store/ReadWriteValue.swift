public struct Getter {
    private let contextKey: String?
    private let store: Store
    
    init(_ context: String? = nil, store: Store = RecoilStore.shared) {
        self.contextKey = context
        self.store = store
    }
    
    public func callAsFunction<T: RecoilSyncNode>(_ recoilValue: T) -> T.T {
        let loadable = getLoadbox(recoilValue)
        
        if loadable.isInitiated {
            loadable.load()
        }
        
        guard let data = loadable.data else {
            let error = loadable.error ?? RecoilError.unknown
            fatalError(error.localizedDescription)
        }
        
        return data
    }
    
    public func callAsFunction<T: RecoilAsyncNode>(_ recoilValue: T) -> T.T? {
        let loadable = getLoadbox(recoilValue)
        
        if loadable.isInitiated {
            loadable.load()
        }
        
        return loadable.data
    }
    
    private func getLoadbox<T: RecoilNode>(_ recoilValue: T) -> LoadBox<T.T> {
        guard let loadable = store.safeGetLoadable(for: recoilValue) as? LoadBox<T.T> else {
            fatalError("Can not convert loadable to loadbox.")
        }
        
        if let host = contextKey {
            store.makeConnect(key: host, upstream: recoilValue.key)
        }
        
        if loadable.isInitiated {
          loadable.load()
        }
        
        return loadable
    }
}

public struct Setter {
    private let contextKey: String?
    private let store: Store
    
    init(_ context: String? = nil, store: Store = RecoilStore.shared) {
        self.store = store
        self.contextKey = context
    }
    
    public func callAsFunction<T: RecoilMutableSyncNode>(_ recoilValue: T, _ newValue: T.T) -> Void {
        _ = store.safeGetLoadable(for: recoilValue)
        
        recoilValue.update(with: newValue)
    }
    
    public func callAsFunction<T: RecoilMutableAsyncNode>(_ recoilValue: T, _ newValue: T.T) -> Void {
        _ = store.safeGetLoadable(for: recoilValue)
        
        recoilValue.update(with: newValue)
    }
}

public struct MutableContext {
    let get: Getter
    let set: Setter
}
