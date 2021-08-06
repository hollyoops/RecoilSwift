public enum LoadingStatus {
    case loading
    case solved
    case error
}

public class LoadableContainer<T: Equatable> {
    public typealias Failure = Error

    private(set) var data: T?
    private(set) var error: Error?
    private(set) var status: LoadingStatus = .solved
    
    private let loader: LoaderProtocol
    private var valueDidChanged: (() -> Void)?
    
    var isAsynchronous: Bool {
        let isSync = loader is ValueLoader<T>
        return !isSync
    }
    
    var isLoading: Bool {
        status == .loading
    }
    
    init(value: T) {
        self.loader = ValueLoader { _ in value }
        fullFill(value)
    }
    
    init(_ body: @escaping GetBody<T>) {
        self.loader = ValueLoader(body)
    }
    
    @available(iOS 13, *)
    init(_ asyncBody: @escaping AsyncGetBody<T, Failure>) {
        self.loader = CombineLoader(asyncBody)
    }
    
    func compute(context: GetterFunction)  {
        if status == .loading {
            self.loader.cancel()
        }
    
        self.status = .loading
        self.loader
            .toPromise()
            .then { [weak self] in self?.fullFill($0) }
            .catch { [weak self] in self?.reject($0) }
            
        self.loader.run(context: context)
    }
    
    func onValueDidChange(_ change: @escaping () -> Void) {
        self.valueDidChanged = change
    }
}

extension LoadableContainer {
    private func fullFill(_ value: T) {
        let isValueChanged = value != data
        
        self.error = nil
        self.data = value
        self.status = .solved
        
        if (isValueChanged) {
            valueDidChanged?()
        }
    }
    
    private func reject(_ error: Failure) {
        self.error = error
        self.status = .error
        
        if isAsynchronous {
            self.data = nil
        }
        // TODO: Compare error only trigger when error changed
        valueDidChanged?()
    }
}

extension LoadableContainer: Equatable {
    public static func ==(lhs: LoadableContainer<T>, rhs: LoadableContainer<T>) -> Bool {
        lhs.status == rhs.status &&
        lhs.data == rhs.data
    }
}
