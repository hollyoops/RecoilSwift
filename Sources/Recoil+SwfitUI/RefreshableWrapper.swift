#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
internal class RefreshableWrapper<Value: IObservableValue>: ObservableObject {
    let value: Value

    init(_ observableValue: Value) {
        value = observableValue
        subscribeValue()
    }
    
    private func subscribeValue() {
        _ = value.observe {
            self.notifyUpdate()
        }
    }
    
    private func notifyUpdate() {
        objectWillChange.send()
    }
}

@available(iOS 13, *)
extension RefreshableWrapper where Value: IRecoilValue {
    convenience init(from recoilValue: Value) {
        self.init(recoilValue)
        value.mount()
    }
    
    func update(_ newValue: Value.WrappedValue) where Value: IRecoilState {
        value.update(newValue)
    }
}

// MARK: - RefreshState + LoadableState

public protocol LoadableState {
    var isLoading: Bool { get  }
    
    var loadingStatus: LoadingStatus { get }
    
    var error: Error? { get }
}

@available(iOS 13, *)
extension RefreshableWrapper: LoadableState where Value: IRecoilValue {
    var isLoading: Bool {
        value.loadable.isLoading
    }

    var loadingStatus: LoadingStatus {
        value.loadable.status
    }

    var error: Error? {
        value.loadable.error
    }
}
