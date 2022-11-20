import SwiftUI

@propertyWrapper
public struct RecoilValue<Node: RecoilSyncNode>: DynamicProperty {
    private var context: ScopedRecoilContext
    private var node: Node
    
    public init(_ node: Node, context: ScopedRecoilContext) {
        self.node = node
        self.context = context
    }
    
    public var wrappedValue: Node.T {
        context.useRecoilValue(node)
    }
}

@propertyWrapper
public struct RecoilState<Node: RecoilMutableNode>: DynamicProperty {
    private var context: ScopedRecoilContext
    private var node: Node
    
    public init(_ node: Node, context: ScopedRecoilContext) {
        self.node = node
        self.context = context
    }
    
    public var wrappedValue: Node.T {
        get { projectedValue.wrappedValue }
        nonmutating set {
            projectedValue.wrappedValue = newValue
        }
    }
    
    public var projectedValue: Binding<Node.T> {
        Binding(context.useRecoilState(node))
    }
}

@propertyWrapper
public struct RecoilValueLoadable<Node: RecoilNode>: DynamicProperty {
    private var context: ScopedRecoilContext
    private var node: Node
    public let wrappedValue: LoadableContent<Node.T>
    
    public init(_ node: Node, context: ScopedRecoilContext) {
        self.node = node
        self.context = context
        self.wrappedValue = context.useRecoilValueLoadable(node)
    }
}
