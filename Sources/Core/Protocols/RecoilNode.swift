public protocol RecoilNode<T> {
    associatedtype T: Equatable
  
    var get: any Evaluator<T> { get }
    
    var key: String { get }
}

public protocol RecoilSyncNode: RecoilNode {
    func data(from: some RecoilLoadable<T>) throws -> T
}

extension RecoilSyncNode {
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

public protocol RecoilAsyncNode: RecoilNode { }

extension RecoilAsyncNode {
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
