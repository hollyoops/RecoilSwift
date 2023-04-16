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
