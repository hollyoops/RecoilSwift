import RecoilSwift

struct TempFahrenheitState: SyncAtomNode {
    typealias T = Int
    func getValue() throws -> Int {
        32
    }
}

struct TempCelsiusSelector: SyncSelectorNode, Writeable {
    typealias T = Int

    func getValue(_ accessor: StateGetter) throws -> Int {
        let fahrenheit = accessor.getUnsafe(TempFahrenheitState())
        return (fahrenheit - 32) * 5 / 9
    }

    func setValue(context: MutableContext, newValue: Int) {
        let newFahrenheit = (newValue * 9) / 5 + 32
        context.accessor.set(TempFahrenheitState(), newFahrenheit)
    }
}

struct ErrorState<Value: Equatable>: SyncAtomNode, Hashable {
    typealias T = Value
    let error: Error
    
    func getValue() throws -> Value {
        throw error
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(error.localizedDescription)
    }
    
    static func == (lhs: ErrorState, rhs: ErrorState) -> Bool {
        lhs.key == rhs.key
    }
}

struct RemoteErrorState<Value: Equatable>: AsyncSelectorNode, Hashable {
    typealias T = Value
    let error: Error
    let delayInNanoSeconds: UInt64 = TestConfig.mock_async_wait_nanoseconds
    
    func getValue(_ accessor: StateGetter) async throws -> Value {
        try? await Task.sleep(nanoseconds: delayInNanoSeconds)
        throw error
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(error.localizedDescription)
    }
    
    static func == (lhs: RemoteErrorState, rhs: RemoteErrorState) -> Bool {
        lhs.key == rhs.key
    }
}
