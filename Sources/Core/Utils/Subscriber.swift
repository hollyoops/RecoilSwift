import Foundation

internal final class Subscriber {
    let id = UUID()
   
    typealias CancelCallback = (Subscriber) -> Void
    typealias ChangeCallback = () -> Void
    
    private var changeCallback: ChangeCallback
    private var cancelCallback: CancelCallback?
    
    init(_ onChange: @escaping ChangeCallback, _ onCancel: CancelCallback? = nil) {
        changeCallback = onChange
        cancelCallback = onCancel
    }
    
    func callAsFunction() {
        changeCallback()
    }
}

extension Subscriber: RecoilCancelable {
    func cancel() {
        self.cancelCallback?(self)
    }
}

extension Subscriber: Equatable {
    static func == (lhs: Subscriber, rhs: Subscriber) -> Bool {
        lhs.id == rhs.id
    }
}
