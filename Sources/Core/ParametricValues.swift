#if canImport(Combine)
import Combine
#endif

public struct ParametricRecoilValue<P, T: RecoilValue> {
    let recoilValue: T
    let param: P
}

public typealias FamilyFunc<P, T: RecoilValue> = (P) -> ParametricRecoilValue<P, T>

public typealias ParametricGetBody<P, T> = (P, Getter) -> T

@available(iOS 13, *)
public typealias ParametricCombineGetBody<P, T,  E: Error> = (P, Getter) throws -> AnyPublisher<T, E>

@available(iOS 15, *)
public typealias ParametricAsyncGetBody<P, T> = (P, Getter) async -> T
