internal final class Ref<Value: RecoilValue> {
    var value: Value
    
    var isDisposed = false
    
    private var subscription: Subscription?
    private var viewUpdator: (() -> Void)?
    
    init(initialState: Value) {
        value = initialState
    }
    
    func update(newValue: Value, viewUpdator: @escaping () -> Void) {
        self.value = newValue
        self.viewUpdator = viewUpdator
   
        // TODO: get rid of the store refer, should pass it from environment
        let storeRef = RecoilStore.shared
        self.subscription = storeRef.subscribe(for: newValue.key, subscriber: self)
        
        let loadable = storeRef.safeGetLoadable(for: newValue)
        if loadable.status == .initiated {
          loadable.load()
        }
    }
    
    func dispose() {
        isDisposed = true
        cancelTasks()
        // TODO: Remove dynamic recoil value in store?
    }
    
    private func cancelTasks() {
        subscription?.unsubscribe()
        subscription = nil
    }
}

extension Ref: Subscriber {
    func valueDidChange() {
        self.viewUpdator?()
    }
}
