class ValueLoader<T: Equatable>: AbstractLoader<T> {
    private var body: GetBody<T>
    
    init(_ syncBody: @escaping GetBody<T>) {
        body = syncBody
    }
    
    override func run(context: GetterFunction) {
        do {
            let value = try body(context)
            fireSuccess(value)
            fireFinish()
        } catch {
            fireError(error)
        }
    }
}
