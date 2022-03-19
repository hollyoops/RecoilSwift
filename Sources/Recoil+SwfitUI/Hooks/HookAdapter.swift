import Hooks
import Foundation

internal func assertMainThread(file: StaticString = #file, line: UInt = #line) {
    assert(Thread.isMainThread, "This API must be called only on the main thread.", file: file, line: line)
}

public typealias HookTester = Hooks.HookTester
public typealias HookView = Hooks.HookView
public typealias HookScope = Hooks.HookScope
