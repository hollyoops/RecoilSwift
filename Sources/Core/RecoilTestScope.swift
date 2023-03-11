import Foundation
import SwiftUI
import Combine

@propertyWrapper
public class RecoilTestScope {
    internal private(set) var store: Store
    internal let viewRefresher = MockViewRefresher()
    internal let caches = ScopedNodeCaches()
    internal let storeSubs = ScopedSubscriptions()
    internal let stateNotifier = PassthroughSubject<(NodeKey, Any), Error>()
    public let timeout: TimeInterval = 3
    
    public var viewRefreshCount: Int { viewRefresher.refreshCount }
    
    public init() {
        self.store = RecoilStore()
    }
    
    public var wrappedValue: ScopedRecoilContext {
        ScopedRecoilContext(store: store,
                            subscriptions: storeSubs,
                            caches: caches,
                            refresher: viewRefresher) { [weak self] pair in
            self?.stateNotifier.send(pair)
        }
    }
    
    public func refresh() {
        viewRefresher.refresh()
    }
    
    public func accessor(deps: [NodeKey]?) -> StateAccessor {
        NodeAccessor(store: store).accessor(deps: deps)
    }
    
    public func reset() {
        store = RecoilStore()
        viewRefresher.reset()
        caches.clear()
    }
    
    @discardableResult
    public func waitNextStateChange(
        timeout: TimeInterval? = nil,
        task: (() -> Void)? = nil
    ) async throws -> (NodeKey, Any) {
        let nodeChangedPub = stateNotifier.eraseToAnyPublisher()
        let timeout = timeout ?? self.timeout
        
        return try await withTimeout(seconds: timeout) {
            async let newState = nodeChangedPub.async()
            async let triggerTask: () = {
                guard let action = task else { return }
                
                try await Task.sleep(nanoseconds: 1_000_000_0)
                action()
            }()
            
            let values = try await (newState, triggerTask)
            
            return values.0
        }
    }
}

public final class MockViewRefresher: ViewRefreshable {
    private(set) var refreshCount: Int = 0
    private let render: (() -> Void)?
    
    init(render: (() -> Void)? = nil) {
        self.render = render
    }
    
    public func refresh() {
        self.refreshCount += 1
        render?()
    }
    
    public func reset() {
        refreshCount = 0
    }
}
