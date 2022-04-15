public struct Getter {
    private let contextKey: String?
    
    init(_ cotext: String? = nil) {
        self.contextKey = cotext
    }
    
    public func callAsFunction<T: RecoilValue>(_ recoilValue: T) -> T.DataType {
        let storeRef = Store.shared
        let loadable = storeRef.getLoadable(for: recoilValue)
        
        if let host = contextKey {
            storeRef.makeConnect(key: host, upstream: recoilValue.key)
        }
        
        if loadable.status == .initiated {
          loadable.load()
        }
      
        return try! recoilValue.data(from: loadable)
    }
}

public struct Setter {
    private let contextKey: String?
    
    init(_ context: String? = nil) {
        self.contextKey = context
    }
    
    public func callAsFunction<T: RecoilState>(_ recoilValue: T, _ newValue: T.DataType) -> Void {
        let storeRef = Store.shared
        
        _ = storeRef.getLoadable(for: recoilValue)
        
        recoilValue.update(with: newValue)
    }
}

public struct MutableContext {
    let get: Getter
    let set: Setter
}
