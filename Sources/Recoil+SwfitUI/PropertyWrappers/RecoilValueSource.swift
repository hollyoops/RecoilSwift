import SwiftUI

@propertyWrapper
public struct RecoilValueSource<Node: RecoilSyncValue>: DynamicProperty {
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
public struct RecoilStateSource<Node: RecoilState>: DynamicProperty {
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

