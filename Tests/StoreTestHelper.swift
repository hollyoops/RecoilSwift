@testable import RecoilSwift

struct RecoilTest {
    private init() {}
    let store = globalStore
    static let shared = RecoilTest()
    
    @MainActor
    func reset() {
        self.store.reset()
    }
    
    var nodeAccessor: NodeAccessor {
        NodeAccessor(store: store)
    }
    
    var accessor: StateAccessor {
        nodeAccessor.accessor(deps: [])
    }
}
