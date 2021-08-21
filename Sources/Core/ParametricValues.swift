#if canImport(Combine)
import Combine
#endif

public struct ParametricRecoilValue<P, T: IRecoilValue> {
    let recoilValue: T
    let param: P
}

public typealias ParametricGetBody<P, T> = (P, ReadOnlyContext) -> T

@available(iOS 13, *)
public typealias ParametricCombineGetBody<P, T,  E: Error> = (P, ReadOnlyContext) throws -> AnyPublisher<T, E>

public typealias FamilyFunc<P, T: IRecoilValue> = (P) -> ParametricRecoilValue<P, T>
