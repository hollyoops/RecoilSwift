import Foundation

#if canImport(Combine)
import Combine
#endif

// MARK: - Sync Selector
public typealias GetBody<T> = (Getter) throws -> T
public typealias SetBody<T> = (MutableContext, T) -> Void

public struct Selector<T: Equatable>: RecoilValue, RecoilSyncReadable {
    public let key: String
    public let get: GetBody<T>
    
    init(key: String = "R-Sel-\(UUID())", body: @escaping GetBody<T>) {
        self.key = key
        self.get = body
    }
}

public struct MutableSelector<T: Equatable>: RecoilValue, RecoilSyncReadable {
    public let key: String
    public let get: GetBody<T>
    public let set: SetBody<T>

    public init(key: String = "WR-Sel-\(UUID())", get: @escaping GetBody<T>, set: @escaping SetBody<T>) {
        self.key = key
        self.get = get
        self.set = set
    }
}

extension MutableSelector: RecoilSyncWriteable { }

// MARK: - Async Selector
@available(iOS 13.0, *)
public typealias CombineGetBody<T: Equatable, E: Error> = (Getter) throws -> AnyPublisher<T, E>

@available(iOS 15.0, *)
public typealias AsyncGetBody<T: Equatable> = (Getter) async throws -> T


public protocol AsyncGet {
    func toLoader(for key: String) -> LoaderProtocol
}

@available(iOS 13.0, *)
struct CombineCallback<T: Equatable, E: Error>: AsyncGet {
    func toLoader(for key: String) -> LoaderProtocol {
        let getFn = self.get
        return CombineLoader { try getFn(Getter(key)) }
    }
    
    public let get: CombineGetBody<T, E>
}

@available(iOS 15.0, *)
struct AsyncCallback<T: Equatable>: AsyncGet {
    public let get: AsyncGetBody<T>
    
    func toLoader(for key: String) -> LoaderProtocol {
        let getFn = self.get
        return AsynchronousLoader { try await getFn(Getter(key)) }
    }
}

@available(iOS 13.0, *)
public struct AsyncSelector<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
    public let key: String
    public let get: AsyncGet

    public init(key: String = "R-AsyncSel-\(UUID())", get: @escaping CombineGetBody<T, E>) {
        self.key = key
        self.get = CombineCallback(get: get)
    }
    
    @available(iOS 15.0, *)
    public init(key: String = "R-AsyncSel-\(UUID())", get: @escaping AsyncGetBody<T>) {
        self.key = key
        self.get = AsyncCallback(get: get)
    }
}

@available(iOS 13.0, *)
public struct MutableAsyncSelector<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
    public let key: String
    public let get: AsyncGet
    public let set: SetBody<T?>

    public init(key: String = "WR-AsyncSel-\(UUID())",
                get: @escaping CombineGetBody<T, E>,
                set: @escaping SetBody<T?>) {
        self.key = key
        self.get = CombineCallback(get: get)
        self.set = set
    }
}

@available(iOS 13.0, *)
extension MutableAsyncSelector: RecoilSyncWriteable { }
