import Foundation

public enum NodeStatus<T: Equatable>: Equatable {
    case invalid
    case loading
    case solved(T)
    case error(Error)
    
    public static func == (lhs: NodeStatus<T>, rhs: NodeStatus<T>) -> Bool {
        switch (lhs, rhs) {
        case (.invalid, .invalid):
            return true
        case (.loading, .loading):
            return true
        case let (.solved(value1), .solved(value2)):
            return value1 == value2
        case let (.error(error1), .error(error2)):
            let nsError1 = error1 as NSError
            let nsError2 = error2 as NSError
            return nsError1.domain == nsError2.domain && nsError1.code == nsError2.code
        default:
            return false
        }
    }
}
