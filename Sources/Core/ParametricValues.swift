#if canImport(Combine)
import Combine
#endif

public struct ParametricRecoilValue<P, Node: RecoilNode> {
    let recoilValue: Node
    let param: P
}

public typealias FamilyFunc<P, T: RecoilNode> = (P) -> ParametricRecoilValue<P, T>

public typealias ParametricGetBody<P, T> = (P, Getter) -> T

public typealias ParametricCombineGetBody<P, T,  E: Error> = (P, Getter) throws -> AnyPublisher<T, E>

public typealias ParametricAsyncGetBody<P, T> = (P, Getter) async -> T

public typealias AtomGet<T> = () throws -> T
public typealias AtomAsyncGet<T> = () async throws -> T
public typealias AtomFamilyGet<P, T> = (P) throws -> T
public typealias AtomFamilyCombineGet<P, T, E: Error> = (P) -> AnyPublisher<T, E>
public typealias AtomFamilyAsyncGet<P, T> = (P) async throws -> T

public typealias GetterGet<T> = (Getter) throws -> T
public typealias SelectorFamilyGet<P, T> = (P, Getter) throws -> T
public typealias SelectorFamilyCombineGet<P, E: Error, T> = (P, Getter) -> AnyPublisher<T, E>
public typealias SelectorFamilyAsyncGet<P, T> = (P, Getter) async throws -> T
