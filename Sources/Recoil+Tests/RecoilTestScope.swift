import Foundation
import SwiftUI
import Combine

@propertyWrapper
public class RecoilTestScope {
    internal var store: RecoilStoreProxy
    internal let viewRefresher = MockViewRefresher()
    internal let stateCache = ScopedStateCache()
    internal let stateNotifier = PassthroughSubject<(NodeKey, Any), Error>()
    public let timeout: TimeInterval = 3
    
    public var viewRefreshCount: Int { viewRefresher.refreshCount }
    
    public init() {
        self.store = RecoilStoreProxy(store: RecoilStore())
    }
    
    public var wrappedValue: ScopedRecoilContext {
        let scope = ScopedRecoilContext(store: store,
                            cache: stateCache,
                            refresher: viewRefresher)
        
        self.stateCache.onValueChange = { [weak self] pair in
            self?.stateNotifier.send(pair)
            self?.refresh()
        }
        
        return scope
    }
    
    public func refresh() {
        viewRefresher.refresh()
    }
    
    public func accessor(deps: [NodeKey]?) -> StateAccessor {
        NodeAccessor(store: store).accessor(deps: deps)
    }
    
    public func stubState<Node: RecoilNode>(node: Node, value: Node.T) {
        store.stub(for: node, with: value)
    }
    
    public func stubState<Node: RecoilNode>(node: Node, error: Error) {
        store.stub(for: node, with: error)
    }
    
    public func purge() {
        store.purge()
        store = RecoilStoreProxy(store: RecoilStore())
        stateCache.clear()
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

        DispatchQueue.main.async {
            self.render?()
        } 
    }
    
    public func reset() {
        refreshCount = 0
    }
}
