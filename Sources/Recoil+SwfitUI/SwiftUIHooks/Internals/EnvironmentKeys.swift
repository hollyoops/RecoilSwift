#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
internal extension EnvironmentValues {
    var hooksRulesAssertionDisabled: Bool {
        get { self[DisableHooksRulesAssertionKey.self] }
        set { self[DisableHooksRulesAssertionKey.self] = newValue }
    }
}

@available(iOS 13, *)
private struct DisableHooksRulesAssertionKey: EnvironmentKey {
    static let defaultValue = false
}
