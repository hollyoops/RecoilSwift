import Combine
import SwiftUI

/// Represents a scoped context for Recoil values, allowing binding and updates.
public class ScopedRecoilContext {
    private weak var store: Store?
    private let stateCache: ScopedStateCache
    private let viewRefresher: ViewRefreshable
 
    init(store: Store, cache: ScopedStateCache, refresher: ViewRefreshable) {
        self.stateCache = cache
        self.store = store
        self.viewRefresher = refresher
        cache.onValueChange = { [weak refresher] _ in refresher?.refresh() }
    }
    
    private var nodeAccessor: NodeAccessor {
        NodeAccessor(store: self.unsafeStore)
    }
    
    public func useRecoilValue<Value: RecoilSyncNode>(_ valueNode: Value) -> Value.T {
        subscribeChange(for: valueNode)
        do {
            return try nodeAccessor.get(valueNode, deps: [])
        } catch {
            // TODO:
            print(error)
            fatalError(error.localizedDescription)
        }
    }
    
    public func useRecoilValue<Value: RecoilAsyncNode>(_ valueNode: Value) -> Value.T? {
        useRecoilValueLoadable(valueNode).data
    }
    
    public func useRecoilState<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> Binding<Value.T> {
        Binding(useRecoilBinding(stateNode))
    }
    
    public func useRecoilBinding<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> BindableValue<Value.T> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  try! self.nodeAccessor.get(stateNode, deps: []) // TODO:
              },
              set: { newState in
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
    
    public func useRecoilState<Value: RecoilMutableAsyncNode>(_ stateNode: Value) -> BindableValue<Value.T?> {
        subscribeChange(for: stateNode)
        return BindableValue(
              get: {
                  self.nodeAccessor.getOrNil(stateNode, deps: [])
              },
              set: { newState in
                  guard let newState else { return }
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
    
    public func useRecoilCallback<T>(_ fn: @escaping Callback<T>) -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: stateCache.store
        )
        return fn(context)
    }
    
    public func useRecoilCallback<T>(_ fn: @escaping AsyncCallback<T>) async throws -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: stateCache.store
        )
        
        return try await fn(context)
    }
    
    public func useRecoilValueLoadable<Value: RecoilNode>(_ valueNode: Value) -> LoadableContent<Value.T> {
        subscribeChange(for: valueNode)
//        let loadble = store?.safeGetLoadable(for: valueNode)
//        if loadble == .invalid {
//            loadble.compute(/*excutatble_info*/)
//        }
        return LoadableContent(node: valueNode, store: unsafeStore)
    }
    
    private var unsafeStore: Store {
        guard let store else {
            fatalError("Should have store! pls make sure the add RecoilRoot in your root of view")
        }
        
        return store
    }
    
    private func subscribeChange<Value: RecoilNode>(for node: Value) {
        guard let store else { return }
        stateCache.subscribe(for: node, in: store)
    }

    func refresh() {
        viewRefresher.refresh()
    }
}
