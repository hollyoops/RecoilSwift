import RecoilSwift

public protocol MockState: Hashable {
    associatedtype Value: Hashable = String
    
    var error: Error? { get }
    var value: Value? { get }
}

public extension MockState where Self: RecoilNode {
    func hash(into hasher: inout Hasher) {
        if let error = error {
            hasher.combine(error.localizedDescription)
        }
        
        if let value = value {
            hasher.combine(value)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key
    }
}

public struct MockAtom<Value: Hashable>: SyncAtomNode, MockState {
    public typealias T = Value
    public let error: Error?
    public let value: Value?
    
    public init(error: Error) {
        self.error = error
        self.value = nil
    }
    
    public init(value: Value) {
        self.error = nil
        self.value = value
    }
    
    public func getValue() throws -> Value {
        if let error = error {
            throw error
        }
        
        if let value = value {
            return value
        }
        
        throw RecoilTestError.invalidState
    }
}

public struct MockAsyncAtom<Value: Hashable>: AsyncAtomNode, MockState {
    public typealias T = Value
    public let error: Error?
    public let value: Value?
    public let delayInNanoSeconds: UInt64
    
    public init(error: Error, delayInNanoSeconds: UInt64 = 100_000_00) {
        self.error = error
        self.value = nil
        self.delayInNanoSeconds = delayInNanoSeconds
    }
    
    public init(value: Value, delayInNanoSeconds: UInt64 = 100_000_00) {
        self.error = nil
        self.value = value
        self.delayInNanoSeconds = delayInNanoSeconds
    }
    
    public func getValue() async throws -> Value {
        try? await Task.sleep(nanoseconds: delayInNanoSeconds)
        
        if let error = error {
            throw error
        }
        
        if let value = value {
            return value
        }
        
        throw RecoilTestError.invalidState
    }
}

public struct MockSelector<Value: Hashable>: SyncSelectorNode, MockState {
    public typealias T = Value
    public let error: Error?
    public let value: Value?
    
    public init(error: Error) {
        self.error = error
        self.value = nil
    }
    
    public init(value: Value) {
        self.error = nil
        self.value = value
    }
    
    public func getValue(_ accessor: StateGetter) throws -> Value {
        if let error = error {
            throw error
        }
        
        if let value = value {
            return value
        }
        
        throw RecoilTestError.invalidState
    }
}

public struct MockAsyncSelector<Value: Hashable>: AsyncSelectorNode, MockState {
    public typealias T = Value
    public let error: Error?
    public let value: Value?
    public let delayInNanoSeconds: UInt64
    
    public init(error: Error, delayInNanoSeconds: UInt64 = 100_000_00) {
        self.error = error
        self.value = nil
        self.delayInNanoSeconds = delayInNanoSeconds
    }
    
    public init(value: Value, delayInNanoSeconds: UInt64 = 100_000_00) {
        self.error = nil
        self.value = value
        self.delayInNanoSeconds = delayInNanoSeconds
    }
    
    public func getValue(_ accessor: StateGetter) async throws -> Value {
        try? await Task.sleep(nanoseconds: delayInNanoSeconds)
        
        if let error = error {
            throw error
        }
        
        if let value = value {
            return value
        }
        
        throw RecoilTestError.invalidState
    }
}
