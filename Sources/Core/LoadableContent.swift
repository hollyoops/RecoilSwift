/// A loadable object that contains loading informations
public struct LoadableContent<DataType: Equatable> {
    public let key: NodeKey
    public let isAsynchronous: Bool
    private let store: Store
    
    init<T: RecoilNode>(node: T, store: Store) {
        self.store = store
        self.key = node.key
        self.isAsynchronous = node is (any RecoilAsyncNode)
        self.initNode(node)
    }
    
    public var data: DataType? {
        accessor.getOrNil(for: key, type: DataType.self, deps: nil)
    }
    
    public var isLoading: Bool {
        accessor.getLoadingStatus(for: key)
    }
    
    public var hasError: Bool {
        !errors.isEmpty
    }
    
    public var errors: [Error] {
        accessor.getErrors(for: key)
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
        accessor.refresh(for: key)
    }
    
    private func initNode<T: RecoilNode>(_ recoilValue: T) {
        accessor.loadNodeIfNeeded(recoilValue)
    }
    
    private var accessor: NodeAccessor {
        NodeAccessor(store: store)
    }
}
