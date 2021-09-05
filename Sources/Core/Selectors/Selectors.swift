import Foundation

#if canImport(Combine)
import Combine
#endif

public typealias ReadonlyContext = Getter
public struct MutableContext {
    let get: Getter
    let set: Setter
}

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

@available(iOS 13.0, *)
public typealias CombineGetBody<T: Equatable, E: Error> = (Getter) throws -> AnyPublisher<T, E>

@available(iOS 13.0, *)
public struct AsyncSelector<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
    public let key: String
    public let get: CombineGetBody<T, E>

    public init(key: String = "R-AsyncSel-\(UUID())", get: @escaping CombineGetBody<T, E>) {
        self.key = key
        self.get = get
    }
}

@available(iOS 13.0, *)
public struct MutableAsyncSelector<T: Equatable, E: Error>: RecoilValue, RecoilAsyncReadable {
    public let key: String
    public let get: CombineGetBody<T, E>
    public let set: SetBody<T?>

    public init(key: String = "WR-AsyncSel-\(UUID())",
                get: @escaping CombineGetBody<T, E>,
                set: @escaping SetBody<T?>) {
        self.key = key
        self.get = get
        self.set = set
    }
}

@available(iOS 13.0, *)
extension MutableAsyncSelector: RecoilSyncWriteable { }
