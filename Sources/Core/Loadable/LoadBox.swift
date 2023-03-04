typealias StatusChangedCallback<T: Equatable> = (NodeStatus<T>) -> Void

internal class SyncLoadBox<T: Equatable>: RecoilLoadable {
    private(set) var onStatusChange: StatusChangedCallback<T>?
    let key: NodeKey
    let computeBody: (StateGetter) throws -> T
    
    init<Node: RecoilSyncNode>(node: Node) where Node.T == T {
        self.key = node.key
        computeBody = { try node.compute($0) }
    }
    
    var status: NodeStatus<T> = .invalid {
        didSet { onStatusChange?(status) }
    }

    func compute(_ ctx: StateGetter) throws -> T {
        do {
            let value = try self.computeBody(ctx)
            self.status = .solved(value)
            return value
        } catch {
            self.status = .error(error)
            throw error
        }
    }
    
    func refresh(_ ctx: StateGetter) {
        _ = try? compute(ctx)
    }
    
    func observeStatusChange(_ change: @escaping (NodeStatus<T>) -> Void) -> Subscription {
        onStatusChange = change
        return Subscription { [weak self] in
            self?.onStatusChange = nil
        }
    }
}

internal class AsyncLoadBox<T: Equatable>: RecoilLoadable {
    let key: NodeKey
    var onStatusChange: StatusChangedCallback<T>?
    let computeBody: (StateGetter) async throws -> T
    
    init<Node: RecoilAsyncNode>(node: Node) where Node.T == T {
        self.key = node.key
        self.computeBody = { try await node.compute($0) }
    }
    
    var status: NodeStatus<T> = .invalid {
        didSet { onStatusChange?(status) }
    }
    
    func compute(_ ctx: StateGetter) -> Task<T, Error> {
        if case let .loading(task) = self.status {
            return task
        }
       
        let task = Task {
            do {
                let val = try await computeBody(ctx)
                self.status = .solved(val)
                return val
            } catch {
                self.status = .error(error)
                throw error
            }
        }
        self.status = .loading(task)
        
        return task
    }
    
    func observeStatusChange(_ change: @escaping (NodeStatus<T>) -> Void) -> Subscription {
        onStatusChange = change
        return Subscription { [weak self] in
            self?.onStatusChange = nil
        }
    }
    
    func cancel() {
        status.task?.cancel()
    }
    
    func refresh(_ ctx: StateGetter) {
        _ = compute(ctx)
    }
}
