import Foundation

public class Atom<T: Equatable> {
    private var subscribers: [Subscriber] = []
    public let key: String

    private var shouldNotify = false
    public var value: T {
        willSet {
            if value != newValue {
                shouldNotify = true
            }
        }
        didSet {
            if shouldNotify {
                notify()
                shouldNotify = false
            }
        }
    }

    public init(_ value: T) {
        self.value = value
        self.key = "Atom-\(UUID())"
    }

    public init(key: String, value: T) {
        self.value = value
        self.key = key
    }

    private func notify() {
        subscribers.forEach { $0() }
    }
}

extension Atom: IRecoilState {
    public typealias DataType = T
    
    public var loadable: LoadableContainer<T> {
        LoadableContainer.init(value: self.value)
    }
    
    public func update(_ value: T) {
        self.value = value
    }

    public func mount() {
        
    }
    
    public func observe(_ change: @escaping () -> Void) -> ICancelable {
        let subscriber = Subscriber(change) { [weak self] sub in
            self?.subscribers.removeAll { sub == $0 }
        }
        subscribers.append(subscriber)

        return subscriber
    }
    
    public var wrappedData: DataType {
        value
    }
}
