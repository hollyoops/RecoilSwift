typealias SynchronousLoaderBody<T: Equatable> = SynchronousLoader<T>.Body

class SynchronousLoader<T: Equatable>: AbstractLoader<T> {
    typealias Body = () throws -> T

    private var body: Body

    init(_ syncBody: @escaping Body) {
        body = syncBody
    }

    override func run() {
        do {
            let value = try body()
            fireSuccess(value)
            fireFinish()
        } catch {
            fireError(error)
        }
    }
}
