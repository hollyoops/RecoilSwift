public protocol Bindable {
    associatedtype Value
    var value: Value { get nonmutating set }
}

public extension Bindable {
    var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }
}

public struct BindableValue<Value>: Bindable {
    let get: () -> Value
    let set: (Value) -> Void
    
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }
    
    public var value: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}

public struct ThrowingBinding<Value> {
    private let get: () throws -> Value
    private let set: (Value) -> Void
    
    public init(get: @escaping () throws -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }
    
    public var value: Value {
        get throws { try get() }
    }
    
    public func setValue(_ newValue: Value) {
        set(newValue)
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension Binding {
    init<T: Bindable>(_ bindable: T) where T.Value == Value {
        self.init(get: { bindable.value }, set: { bindable.value = $0 } )
    }
}
#endif
