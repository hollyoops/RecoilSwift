public protocol SyncSelectorReadable: RecoilSyncReadable {
    var get: GetBody<T> { get }
}

extension SyncSelectorReadable {
    public func makeLoadable() -> LoadBox<T, Error> {
        let getFn = self.get
        let key = self.key
        let loader = SynchronousLoader { try getFn(Getter(key)) }
        return LoadBox(loader: loader)
    }
}

public protocol AsyncSelectorReadable: RecoilAsyncReadable { }
