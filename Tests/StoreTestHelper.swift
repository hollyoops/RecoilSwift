@testable import RecoilSwift

struct RecoilTest {
    private init() {}
    let store = globalStore
    static let shared = RecoilTest()
    
    func reset() {
        self.store.reset()
    }
    
    var nodeAccessor: NodeAccessor {
        NodeAccessor(store: store)
    }
}
