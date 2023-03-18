public enum RecoilError: Error, Equatable, CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "RecoilError.unkown"
        case .circular(let info): return info.description
        }
    }
    
    public struct CircularInfo: Equatable, CustomStringConvertible {
        public let key: NodeKey
        public let deps: [NodeKey]
        
        public var stackMessaage: String {
            deps.map { $0.name }
                .joined(separator: " -> ")
                .appending(" -> \(key.name)")
        }
        
        public var description: String {
            "RecoilError.Circular(deps: [\(stackMessaage)])"
        }
    }
    
    case unknown
    case circular(CircularInfo)
    
    public static func == (lhs: RecoilError, rhs: RecoilError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case let (.circular(lInfo), .circular(rInfo)):
            return lInfo == rInfo
        default:
            return false
        }
    }
}
