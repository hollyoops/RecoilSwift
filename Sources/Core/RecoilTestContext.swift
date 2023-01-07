import Foundation
import SwiftUI
import Combine

public final class MockViewRefresher: ViewRefreshable {
    internal let notifier = PassthroughSubject<Void, Never>()
    
    private(set) var refreshCount: Int = 0
    func refresh() {
        refreshCount += 1
        notifier.send()
    }
    
    public func reset() {
        refreshCount = 0
    }
}

@propertyWrapper
public class RecoilTestScope {
    private var store: Store
    private var viewRefersher = MockViewRefresher()
    private let storeSubs = ScopedSubscriptions()
    
    var viewRefreshCount: Int { viewRefersher.refreshCount }
    
    public init() {
        self.store = RecoilStore()
    }

    public var wrappedValue: RecoilTestContext {
        RecoilTestContext(store: store,
                            subscriptions: storeSubs,
                            refresher: viewRefersher)
    }
    
    public func refresh() {
        viewRefersher.refresh()
    }
    
    public func reset() {
        store = RecoilStore()
        viewRefersher.reset()
    }
}

public enum RecoilTestContextError: Error {
    case unknown
}

public class RecoilTestContext {
    private let context: ScopedRecoilContext
    
    internal init(store: Store,
                  subscriptions: ScopedSubscriptions,
                  refresher: ViewRefreshable) {
        self.context = ScopedRecoilContext(store: store,
                                           subscriptions: subscriptions,
                                           refresher: refresher)
    }
    
    public func waitForNodeChange<Node: RecoilNode>(
        node: Node,
        timeout: TimeInterval = 5.0
    ) async throws -> NodeStatus<Node.T> {
        let nodeChangedPub = context.stateNotifier.filter { (key, _) in key == node.key }
            .tryMap { (_, status) in
                guard let value = status as? NodeStatus<Node.T> else {
                    throw RecoilTestContextError.unknown
                }
                return value
            }
            .eraseToAnyPublisher()
        
        return try await withTimeout(seconds: UInt(timeout)) {
            try await nodeChangedPub.async()
        }()
    }
    
    public func waitForViewRefresh(timeout: TimeInterval = 5.0) async throws {
        let nodeChangedPub = (context.viewRefresher as! MockViewRefresher).notifier
            .tryMap { $0 }
            .eraseToAnyPublisher()
        
        return try await withTimeout(seconds: UInt(timeout)) {
            try await nodeChangedPub.async()
        }()
    }
    
    public func waitForNodeChange(timeout: TimeInterval = 5.0) async throws -> (String, Any) {
        let nodeChangedPub = context.stateNotifier
            .tryMap { $0 }
            .eraseToAnyPublisher()
        
        return try await withTimeout(seconds: UInt(timeout)) {
            try await nodeChangedPub.async()
        }()
    }
}


extension RecoilTestContext {
    public func useRecoilValue<Value: RecoilSyncNode>(_ valueNode: Value) -> Value.T {
        context.useRecoilValue(valueNode)
    }
    
    public func useRecoilState<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> BindableValue<Value.T> {
        context.useRecoilState(stateNode)
    }
    
    public func useRecoilValueLoadable<Value: RecoilNode>(_ node: Value) -> LoadableContent<Value.T> {
        context.useRecoilValueLoadable(node)
    }
}
