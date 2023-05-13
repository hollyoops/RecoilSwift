import Combine
import SwiftUI
import Foundation

/// Represents a scoped context for Recoil values, allowing binding and updates.
public class ScopedRecoilContext {
    private weak var store: Store?
    private let stateCache: ScopedStateCache
    private let viewRefresher: ViewRefreshable
 
    init(store: Store, cache: ScopedStateCache, refresher: ViewRefreshable) {
        self.stateCache = cache
        self.store = store
        self.viewRefresher = refresher
        cache.onValueChange = { [weak refresher] _ in
            DispatchQueue.main.async {
                refresher?.refresh()
            }
        }
    }
    
    private var nodeAccessor: NodeAccessor {
        NodeAccessor(store: self.unsafeStore)
    }
    
    public func useValue<Value: RecoilNode>(_ valueNode: Value) -> Value.T? {
        subscribeChange(for: valueNode)
        guard let data = useLoadable(valueNode).data else { return nil }
        return data
    }
    
    public func useBinding<Value: RecoilNode & Writeable>(_ node: Value, `default`: Value.T) -> Binding<Value.T> {
        subscribeChange(for: node)
        return Binding(
            get: {
                 self.nodeAccessor.getOrNil(node, deps: []) ?? `default`
            },
            set: { newState in
                self.nodeAccessor.set(node, newState)
            }
        )
    }
    
    public func useLoadable<Value: RecoilNode>(_ valueNode: Value) -> LoadableContent<Value.T> {
        subscribeChange(for: valueNode)
        return LoadableContent(node: valueNode, store: unsafeStore)
    }
    
    public func useUpdate<Value: RecoilNode & Writeable>(_ stateNode: Value) -> (Value.T) -> Void {
        subscribeChange(for: stateNode)
        return { newState in
            self.nodeAccessor.set(stateNode, newState)
        }
    }

    public func useCallback<T>(_ fn: @escaping Callback<T>) -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: stateCache.store
        )
        return fn(context)
    }
    
    public func useCallback<T>(_ fn: @escaping AsyncCallback<T>) async throws -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: stateCache.store
        )
        
        return try await fn(context)
    }
    
    public func useCallback<T, P>(_ fn: @escaping Callback1<P, T>) -> (P) -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: stateCache.store
        )
        
        return { p in fn(context, p) }
    }
    
    public func useCallback<T, P>(_ fn: @escaping AsyncCallback1<P, T>) -> (P) async throws -> T {
        let context = RecoilCallbackContext(
            accessor: nodeAccessor.accessor(deps: nil),
            store: stateCache.store
        )
        
        return { p in try await fn(context, p) }
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

extension ScopedRecoilContext {
    public func useUnsafeValue<Value: RecoilSyncNode>(_ valueNode: Value) -> Value.T {
        try! useThrowingValue(valueNode)
    }
    
    public func useThrowingValue<Value: RecoilSyncNode>(_ valueNode: Value) throws -> Value.T {
        subscribeChange(for: valueNode)
        return try nodeAccessor.get(valueNode, deps: [])
    }
    
    public func useUnsafeBinding<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> Binding<Value.T> {
        subscribeChange(for: stateNode)
        return Binding(
              get: {
                  try! self.nodeAccessor.get(stateNode, deps: [])
              },
              set: { newState in
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
    
    public func useThrowingBinding<Value: RecoilMutableSyncNode>(_ stateNode: Value) -> ThrowingBinding<Value.T> {
        subscribeChange(for: stateNode)
        return ThrowingBinding(
              get: {
                  try self.nodeAccessor.get(stateNode, deps: [])
              },
              set: { newState in
                  self.nodeAccessor.set(stateNode, newState)
              }
          )
    }
}
