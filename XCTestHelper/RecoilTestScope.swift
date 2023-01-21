import Foundation
import SwiftUI
import Combine
import XCTest

@testable import RecoilSwift

@propertyWrapper
public class RecoilTestScope {
    fileprivate var store: Store
    fileprivate let viewRefresher = MockViewRefresher()
    fileprivate let caches = ScopedNodeCaches()
    fileprivate let storeSubs = ScopedSubscriptions()
    fileprivate let stateNotifier = PassthroughSubject<(NodeKey, Any), Error>()
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

final public class ViewRenderHelper {
    public typealias Body = (ScopedRecoilContext, TestSuit) -> Void
    
    private let expectation = XCTestExpectation(description: "View Rerender")
    private let scope: RecoilTestScope
    public let body: Body
    
    public init(
        scope: RecoilTestScope = RecoilTestScope(),
        body: @escaping Body
    ) {
        self.body = body
        self.scope = scope
    }
    
    @discardableResult
    public func waitForRender(
        timeout: TimeInterval? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async -> XCTWaiter.Result {
        let timeout = timeout ?? scope.timeout
        
        renderBody()
        
        let result = await XCTWaiter.fulfillment(of: [expectation], timeout: timeout)
        if result == .timedOut {
            XCTFail("Test render timed out. (file: \(file), line: \(line))")
        }
        
        return result
    }
    
    internal func renderBody() {
        let refresher = MockViewRefresher {
            self.renderBody()
        }
        let ctx = ScopedRecoilContext(store: scope.store,
                                      subscriptions: scope.storeSubs,
                                      caches: scope.caches,
                                      refresher: refresher)
        body(ctx, TestSuit(expectation: expectation))
    }
    
    public func reset() {
        scope.reset()
    }
}
