@available(iOS 13.0, *)
public typealias AsyncGetFunc<T: Equatable> = (Getter) async throws -> T

@available(iOS 13.0, *)
public typealias AsyncGetBodyFunc<T: Equatable> = () async throws -> T

@available(iOS 13.0, *)
struct AsyncGetBody<T: Equatable>: AsyncEvaluator {
    typealias Body = AsyncGetBodyFunc<T>

    private var body: Body

    init(_ asyncBody: @escaping Body) {
        body = asyncBody
    }

    func evaluate() async throws -> T {
        return try await body()
    }
}
