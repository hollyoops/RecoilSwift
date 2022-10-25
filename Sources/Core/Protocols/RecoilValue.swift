public protocol RecoilIdentifiable {
    var key: String { get }
}

public protocol RecoilValue<T, E>: RecoilIdentifiable {
    associatedtype T: Equatable
  
    associatedtype E: Error
  
    associatedtype DataType: Equatable = T
  
    var get: any Evaluator<T> { get }
    
    func data(from: some RecoilLoadable<T, Error>) throws -> DataType
}

public protocol RecoilSyncReadable: RecoilValue { }

extension RecoilSyncReadable {
    public func data(from loadable: some RecoilLoadable<T, Error>) throws -> T {
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
    public func data(from loadable: some RecoilLoadable<T, Error>) -> T? {
        return loadable.data
    }
}

enum RecoilError: Error {
  case unknown
}
