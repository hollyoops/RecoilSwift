import SwiftUI

@available(iOS 14.0, *)
@propertyWrapper
public struct RecoilScopedState<Node: RecoilNode>: DynamicProperty {
    @Environment(\.store) private var store
    
    @StateObject private var viewRefersher: ViewRefresher = ViewRefresher()
    private let cache = ScopedStateCache()
    private var node: Node
    
    public init(_ node: Node) {
        self.node = node
    }
    
    public var wrappedValue: Node.T? {
        projectedValue.data
    }
    
    public var projectedValue: LoadableContent<Node.T> {
        context.useLoadable(node)
    }
    
    private var context: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            cache: cache,
                            refresher: viewRefersher)
    }
}

@available(iOS 14.0, *)
extension RecoilScopedState where Node: RecoilSyncNode {
    public var value: Node.T {
        get throws {
            try context.useThrowingValue(node)
        }
    }
    
    public var unsafeValue: Node.T {
        do {
           return try context.useThrowingValue(node)
        } catch {
            // TODO:
            print(error)
            fatalError(error.localizedDescription)
        }
    }
}

@available(iOS 14.0, *)
extension RecoilScopedState where Node: RecoilMutableSyncNode {
    public var binding: ThrowingBinding<Node.T> {
        context.useThrowingBinding(node)
    }
}

//@available(iOS 14.0, *)
//extension RecoilScopedState where Node: RecoilMutableAsyncNode {
//    public var binding: Binding<Node.T?> {
//        context.useBinding(node)
//    }
//}
