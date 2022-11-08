import Foundation

internal protocol ViewRefreshable: AnyObject {
    func refresh()
}

internal final class AnyViewRefreher: ViewRefreshable {
    let viewUpdator: () -> Void
    
    init(viewUpdator: @escaping () -> Void) {
        self.viewUpdator = viewUpdator
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.viewUpdator()
        }
    }
}
