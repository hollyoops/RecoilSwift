typealias AsynchronousLoaderBody<T: Equatable> = AsynchronousLoader<T>.Body

class AsynchronousLoader<T: Equatable>: AbstractLoader<T> {
    typealias Body = () async throws -> T

    private var body: Body

    init(_ syncBody: @escaping Body) {
        body = syncBody
    }

    override func run() {
        Task {
            do {
                let value = try await body()
                await MainActor.run {
                    fireSuccess(value)
                    fireFinish()
                }
            } catch {
                await MainActor.run {
                    fireError(error)
                }
            }
        }
    }
}
