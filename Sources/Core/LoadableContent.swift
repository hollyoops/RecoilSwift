/// A loadable object that contains loading informations
public struct LoadableContent<DataType: Equatable> {
    public let key: NodeKey
    private let store: Store
    
    init<T: RecoilNode>(node: T, store: Store) {
        self.store = store
        self.key = node.key
        self.initNode(node)
    }

    public var isAsynchronous: Bool {
        guard let loadable = store.getLoadable(for: key) else {
            return false
        }
        
        return loadable is AsyncLoadBox<DataType>
    }
    
    public var data: DataType? {
        store.getLoadable(for: key)?.anyData as? DataType
    }
    
    public var isLoading: Bool {
        store.getLoadingStatus(for: key)
    }
    
    public var hasError: Bool {
        !errors.isEmpty
    }
    
    public var errors: [Error] {
        store.getErrors(for: key)
    }
    
    public func containError<T: Error & Equatable>(of err: T) -> Bool {
        errors.contains { e in
            if let concreteError = e as? T {
                return concreteError == err
            }
            return false
        }
    }
    
    public func refresh() {
        NodeAccessor(store: store).refresh(for: key)
    }
    
    private func initNode<T: RecoilNode>(_ recoilValue: T) {
        NodeAccessor(store: store).loadNodeIfNeeded(recoilValue)
    }
}
