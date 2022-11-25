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

extension NodeStatus {
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    public var isInvalid: Bool {
        if case .invalid = self { return true }
        return false
    }
    
    public var data: T? {
        guard case let .solved(value) = self else {
            return nil
        }
        
        return value
    }
    
    public var error: Error? {
        guard case let .error(err) = self else {
            return nil
        }
        
        return err
    }
}
