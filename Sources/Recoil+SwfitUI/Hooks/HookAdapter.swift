import Hooks
import SwiftUI
import Foundation

internal func assertMainThread(file: StaticString = #file, line: UInt = #line) {
    assert(Thread.isMainThread, "This API must be called only on the main thread.", file: file, line: line)
}

public typealias HookView = Hooks.HookView
public typealias HookScope = Hooks.HookScope

public final class HookTester<Parameter, Value> {
    public var value: Value { tester.value }

    public var valueHistory: [Value] { tester.valueHistory}
    
    private var tester: Hooks.HookTester<Parameter, Value>
    
    public init(
        _ initialParameter: Parameter,
        _ hook: @MainActor @escaping (Parameter) -> Value,
        environment: (inout EnvironmentValues) -> Void = { _ in }
    ) {
        tester = Hooks.HookTester(initialParameter, hook, environment: environment)
    }
    
    public convenience init(
        scope: RecoilTestScope,
        _ hook: @MainActor @escaping (Parameter) -> Value
    ) where Parameter == Void {
        self.init((), hook, environment: { $0.store = scope.store })
    }

    public func update(with parameter: Parameter) {
        tester.update(with: parameter)
    }

    public func update() {
        tester.update()
    }

    public func dispose() {
        tester.dispose()
    }
}
