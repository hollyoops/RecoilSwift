public protocol RecoilSyncReadable {
    associatedtype T: Equatable

    var get: GetBody<T> { get }
}

extension RecoilSyncReadable where Self: RecoilValue {
    public typealias DataType = T
    
    public typealias LoadableType = LoadBox<T, Error>
    
    public func data(from loadable: Loadable) throws -> T {
        guard let loadBox = loadable as? LoadBox<T, Error> else {
            fatalError("Can not convert loadable to synchronous selector.")
        }
        
        if loadBox.status == .initiated {
          loadBox.load()
        }
      
        guard let data = loadBox.data else {
          throw loadBox.error ?? RecoilError.unknown
        }
        
        return data
    }
    
    public func makeLoadable() -> LoadBox<T, Error> {
        let getFn = self.get
        let key = self.key
        let loader = SynchronousLoader { try getFn(Getter(key)) }
        return LoadBox(loader: loader)
    }
}

public protocol RecoilAsyncReadable {
    associatedtype T: Equatable
    
    associatedtype E: Error = Error
   
    var get: AsyncGet { get }
}

extension RecoilAsyncReadable where Self: RecoilValue {
    public typealias DataType = T?
    public typealias LoadableType = LoadBox<T, E>
    
    public func data(from loadable: Loadable) -> T? {
        guard let loadBox = loadable as? LoadBox<T, E> else {
            debugPrint("Can not convert loadable to asynchronous selector.")
            return nil
        }
        
        return loadBox.data
    }
    
    public func makeLoadable() -> LoadBox<T, E> {
        return LoadBox(loader: get.toLoader(for: self.key))
    }
}

public protocol RecoilSyncWriteable: RecoilWriteable {
    var set: SetBody<DataType> { get }
}

extension RecoilSyncWriteable where Self: RecoilValue {
    public func update(with value: DataType) {
        let context = MutableContext(
            get: Getter(key),
            set: Setter(key))
        set(context, value)
    }
}
