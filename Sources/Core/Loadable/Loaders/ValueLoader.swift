typealias ValueGetBody<T> = () throws -> T

class ValueLoader<T: Equatable>: AbstractLoader<T> {
    private var body: ValueGetBody<T>
    
    init(_ syncBody: @escaping ValueGetBody<T>) {
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
