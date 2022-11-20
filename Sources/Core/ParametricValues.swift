#if canImport(Combine)
import Combine
#endif

public struct ParametricRecoilValue<P, T: RecoilNode> {
    let recoilValue: T
    let param: P
}

public typealias FamilyFunc<P, T: RecoilNode> = (P) -> ParametricRecoilValue<P, T>

public typealias ParametricGetBody<P, T> = (P, Getter) -> T

@available(iOS 13, *)
public typealias ParametricCombineGetBody<P, T,  E: Error> = (P, Getter) throws -> AnyPublisher<T, E>

@available(iOS 13, *)
public typealias ParametricAsyncGetBody<P, T> = (P, Getter) async -> T
