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

internal struct CustomHashCalculator {
    typealias HashCalculationBlock = (inout Hasher) -> Void
    
    let calculateHash: HashCalculationBlock
    let hashValue: Int
    
    init(calculateHash: @escaping HashCalculationBlock) {
        self.calculateHash = calculateHash
        
        var hasher = Hasher()
        calculateHash(&hasher)
        self.hashValue = hasher.finalize()
    }
}

public struct NodeKey: RecoilKey {
    public enum NodeType {
        case atom
        case selector
    }
    
    public typealias HashRuleBlock = (inout Hasher) -> Void
    
    public let name: String
    public let position: SourcePosition?
    public let extraHashValue: Int?
    public let nodeType: NodeType
    
    public var fullKeyName: String {
        guard let pos = position else { return name }
        return "\(name)_\(pos.fileName)_\(pos.line)"
    }
    
    init<Node: RecoilNode>(_ node: Node) {
        self.name = String(describing: Node.self)
        
        if let hashableNode = node as? (any Hashable) {
            self.extraHashValue = hashableNode.hashValue
        } else {
            self.extraHashValue = nil
        }
        
        self.nodeType = node.nodeType
        self.position = nil
    }
    
    init(position: SourcePosition, type: NodeType, hashRule: HashRuleBlock? = nil) {
        self.name = position.tokenName
        self.position = position
        self.extraHashValue = hashRule.map { CustomHashCalculator(calculateHash: $0).hashValue }
        self.nodeType = type
    }
    
    init(_ uniqueName: String, type: NodeType,  hashRule: HashRuleBlock? = nil) {
        self.name = uniqueName
        self.position = nil
        self.extraHashValue = hashRule.map { CustomHashCalculator(calculateHash: $0).hashValue }
        self.nodeType = type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fullKeyName)
        
        if let hashableNode = extraHashValue {
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

private extension RecoilNode {
    var nodeType: NodeKey.NodeType {
        let isSyncAtom = (self as? (any SyncAtomNode)).isSome
        let isAsyncAtom = (self as? (any AsyncAtomNode)).isSome
        let isAtom = isSyncAtom || isAsyncAtom
        
        return isAtom ? .atom : .selector
    }
}
