public protocol RecoilIdentifiable {
    var key: String { get }
}

public protocol RecoilValue: RecoilIdentifiable {
    associatedtype T: Equatable
  
    associatedtype E: Error
  
    associatedtype DataType: Equatable = T
  
    var get: AnyGetBody<T> { get }
    
    func data(from: some RecoilLoadable) throws -> DataType
}

public protocol RecoilSyncReadable: RecoilValue { }

extension RecoilSyncReadable {
    public func data(from loadable: some RecoilLoadable) throws -> T {
        guard let loadBox = loadable as? LoadBox<T, E> else {
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
}

public protocol RecoilAsyncReadable: RecoilValue { }

extension RecoilAsyncReadable {
    public func data(from loadable: some RecoilLoadable) -> T? {
        guard let loadBox = loadable as? LoadBox<T, E> else {
            debugPrint("Can not convert loadable to asynchronous selector.")
            return nil
        }

        return loadBox.data
    }
}

enum RecoilError: Error {
  case unknown
}
