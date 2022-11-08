public protocol RecoilIdentifiable {
    var key: String { get }
}

public protocol RecoilValue<T>: RecoilIdentifiable {
    associatedtype T: Equatable
  
    var get: any Evaluator<T> { get }
}

public protocol RecoilSyncValue: RecoilValue {
    func data(from: some RecoilLoadable<T>) throws -> T
}

extension RecoilSyncValue {
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

public protocol RecoilAsyncValue: RecoilValue { }

extension RecoilAsyncValue {
    public func data(from loadable: some RecoilLoadable<T>) throws -> T? {
        if loadable.status == .initiated {
            loadable.load()
        }
        
        return loadable.data
    }
}

enum RecoilError: Error {
  case unknown
}
