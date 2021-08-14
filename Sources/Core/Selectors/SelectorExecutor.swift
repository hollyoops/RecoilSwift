public class SelectorExecutor<T: Equatable> {
    typealias State = T

    public let key: String
    
    private(set) var loadable: LoadableContainer<T>!
    private var hasInit = false
    private var hasBinding = false
    private var subscribsers: [Subscriber] = []
    private var dependencies: [String: ICancelable] = [:]

    init(key: String, getBody: @escaping GetBody<T>) {
        self.key = key
        let body: SynchronousLoaderBody<T> = { [unowned self] in
           return try getBody(self.makeContext())
        }
        
        initLoadable(with: LoadableContainer(synchronous: body))
    }
    
    @available(iOS 13, *)
    init(key: String, getBody: @escaping CombineGetBody<T, Error>) {
         self.key = key
         let body: CombineLoaderBody<T, Error> = { [unowned self] in
             return try getBody(self.makeContext())
         }
         
        initLoadable(with: LoadableContainer(combine: body))
    }
    
    private func initLoadable(with value: LoadableContainer<T>) {
        self.loadable = value
        _ = self.loadable.observe { [weak self] in
            self?.notifyValueDidChanged()
        }
    }

    private func notifyValueDidChanged() {
        self.subscribsers.forEach { $0() }
    }
}

extension SelectorExecutor {
    public func initNode() {
        if (hasInit) {
            return
        }

        hasInit = true
        return compute()
    }

    public func observe(_ change: @escaping () -> Void) -> ICancelable {
        let subscriber = Subscriber(change) { [weak self] sub in
            self?.subscribsers.removeAll { sub == $0 }
        }
        subscribsers.append(subscriber)

        return subscriber
    }
    
    private func makeContext() -> ReadOnlyContext {
        ReadOnlyContext { [weak self] in
            self?.bind($0)
        }
    }

    private func bind(_ value: ReadOnlyContext.SideEffectType) -> Void {
        guard dependencies[value.key] == nil else { return }

        let cancel = value.observe { [weak self] in
            self?.compute()
        }

        dependencies[value.key] = cancel
    }

    private func compute() {
        loadable.compute()
    }
}
