internal final class Ref<Value> {
    private(set) var value: Value
    private(set) var isDisposed = false
    
    internal let storeSubs = ScopedSubscriptions()
    private(set) var ctx: ScopedRecoilContext?
    
    init(initialState: Value) {
        value = initialState
    }
    
    func update(newValue: Value,
                context: ScopedRecoilContext) {
        self.value = newValue
        self.ctx = context
    }
    
    func dispose() {
        isDisposed = true
    }
}
