public protocol RecoilKey: Hashable {
    var name: String { get }
}

public extension RecoilKey { }

public struct NodeKey: RecoilKey {
    public typealias HashCalculator = (inout Hasher) -> Void
    
    public let name: String
    public let recoilNode: AnyHashable?
    public let additionalHashRule: HashCalculator?
    
    init<Node: RecoilNode>(_ node: Node, hashRule: HashCalculator? = nil) {
        self.name = String(describing: Node.Type.self)
        
        if let hashableNode = node as? (any Hashable) {
            self.recoilNode = AnyHashable(hashableNode)
        } else {
            self.recoilNode = nil
        }
        
        self.additionalHashRule = hashRule
    }
    
    init(name: String, hashRule: HashCalculator? = nil) {
        self.name = name
        self.recoilNode = nil
        self.additionalHashRule = hashRule
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        additionalHashRule?(&hasher)
        if let hashableNode = recoilNode {
            hasher.combine(hashableNode)
        }
    }
    
    public static func == (lhs: NodeKey, rhs: NodeKey) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

func sourceLocationKey<T>(_ type: T.Type,
                       fileName: String,
                       line: Int) -> String {
    "\(type)_\(fileName)_\(line)"
}
