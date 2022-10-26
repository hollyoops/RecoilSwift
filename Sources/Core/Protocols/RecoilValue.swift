public protocol RecoilIdentifiable {
    var key: String { get }
}

public protocol RecoilValue<T>: RecoilIdentifiable {
    associatedtype T: Equatable
  
    associatedtype DataType: Equatable = T
  
    var get: any Evaluator<T> { get }
    
    func data(from: some RecoilLoadable<T>) throws -> DataType
}

public protocol RecoilSyncReadable: RecoilValue { }

extension RecoilSyncReadable {
    public func data(from loadable: some RecoilLoadable<T>) throws -> T {
        if loadable.status == .initiated {
            loadable.load()
        }
      
        guard let data = loadable.data else {
          throw loadable.error ?? RecoilError.unknown
        }
        
        return data
    }
}

public protocol RecoilAsyncReadable: RecoilValue { }

extension RecoilAsyncReadable {
    public func data(from loadable: some RecoilLoadable<T>) -> T? {
        return loadable.data
    }
}

enum RecoilError: Error {
  case unknown
}
