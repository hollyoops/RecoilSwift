internal final class Ref<Value: RecoilValue> {
    var value: Value {
        willSet { cancelTasks() }
    }
    
    var isDisposed = false
    var storeSubscriber: Subscriber?
    
    init(initialState: Value) {
        value = initialState
    }
    
    func update(newValue: Value, viewUpdator: @escaping () -> Void) {
        value = newValue
   
        let storeRef = Store.shared
        self.storeSubscriber = storeRef.addObserver(forKey: newValue.key) {
            viewUpdator()
        }
        
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
        storeSubscriber?.cancel()
        
        storeSubscriber = nil
    }
}
