import Combine

public struct RecoilCallbackContext {
    public let accessor: StateAccessor
    public let store: (AnyCancellable) -> Void
}

public typealias Callback<R> = (RecoilCallbackContext) -> R

public typealias AsyncCallback<R> = (RecoilCallbackContext) async throws -> R

public typealias Callback1<P, R> = (RecoilCallbackContext, P) -> R

public typealias AsyncCallback1<P, R> = (RecoilCallbackContext, P) async throws -> R

public typealias Callback2<P1, P2, R> = (RecoilCallbackContext, P1, P2) -> R

public typealias AsyncCallback2<P1, P2, R> = (RecoilCallbackContext, P1, P2) async throws -> R
