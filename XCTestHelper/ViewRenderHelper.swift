import Foundation
import XCTest

@testable import RecoilSwift

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
