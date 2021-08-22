#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13, *)
internal class RefreshableWrapper<Value: IObservableValue>: ObservableObject {
    let value: Value

    init(observable value: Value) {
        self.value = value
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
    convenience init(recoil value: Value) {
        self.init(observable: value)
        value.mount()
    }
    
    func update(_ newValue: Value.DataType) where Value: IRecoilState {
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
