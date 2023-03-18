public protocol RecoilKey: Hashable {
    var name: String { get }
}

public extension RecoilKey { }

public struct SourcePosition: Hashable {
    public let tokenName: String
    public let fileName: String
    public let line: Int
    
    init(funcName: String, fileName: String, line: Int) {
        self.tokenName = funcName
        self.fileName = fileName
        self.line = line
    }
}

public struct NodeKey: RecoilKey {
    public typealias HashCalculator = (inout Hasher) -> Void
    
    public let name: String
    public let position: SourcePosition?
    public let recoilNode: AnyHashable?
    public let additionalHashRule: HashCalculator?
    
    public var fullKeyName: String {
        guard let pos = position else { return name }
        return "\(name)_\(pos.fileName)_\(pos.line)"
    }
    
    init<Node: RecoilNode>(_ node: Node, hashRule: HashCalculator? = nil) {
        self.name = String(describing: Node.self)
        
        if let hashableNode = node as? (any Hashable) {
            self.recoilNode = AnyHashable(hashableNode)
        } else {
            self.recoilNode = nil
        }
        
        self.position = nil
        self.additionalHashRule = hashRule
    }
    
    init(position: SourcePosition, hashRule: HashCalculator? = nil) {
        self.name = position.tokenName
        self.recoilNode = nil
        self.additionalHashRule = hashRule
        self.position = position
    }
    
    init(_ uniqueName: String, hashRule: HashCalculator? = nil) {
        self.name = uniqueName
        self.recoilNode = nil
        self.position = nil
        self.additionalHashRule = hashRule
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        additionalHashRule?(&hasher)
        
        if let hashableNode = recoilNode {
            hasher.combine(hashableNode)
        }
        
        if let pos = position {
            hasher.combine(pos)
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
