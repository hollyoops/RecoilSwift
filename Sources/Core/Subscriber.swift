import Foundation

struct Subscriber {
    let id = UUID()
    
    private var callback: () -> Void
    private var cancelCallback: (() -> Void)?
    
    init(_ body: @escaping () -> Void) {
        callback = body
    }
    
    func callAsFunction() {
        callback()
    }
    
    mutating func withCancel(_ cancel: @escaping () -> Void) {
        cancelCallback = cancel
    }
}

extension Subscriber: ICancelable {
    func cancel() {
        self.cancelCallback?()
    }
}

extension Subscriber: Equatable {
    static func == (lhs: Subscriber, rhs: Subscriber) -> Bool {
        lhs.id == rhs.id
    }
}
