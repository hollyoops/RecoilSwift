public typealias SyncGetFunc<T> = (Getter) throws -> T

public typealias SyncGetBodyFunc<T: Equatable> = () throws -> T

struct SyncGetBody<T: Equatable>: SyncEvaluator {
    typealias Body = SyncGetBodyFunc<T>

    private let body: Body

    init(_ syncBody: @escaping Body) {
        body = syncBody
    }

    func evaluate() throws -> T {
        return try body()
    }
}
