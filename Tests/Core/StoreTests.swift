import XCTest
@testable import RecoilSwift

class RecoilStoreTests: XCTestCase {
    var store: Store!

    @RecoilTestScope var scope
    
    override func setUp() {
        super.setUp()
        store = _scope.store
    }
    
    override func tearDown() {
        store = nil
        _scope.reset()
        super.tearDown()
    }
    
    func test_should_subscribe_when_subscribeIsCalled_given_validNodeKeyAndSubscriber() {
        let mockSubscriber = MockSubscriber()
        let subscription = store.subscribe(for: MockAtoms.intState.key, subscriber: mockSubscriber)
        let obj = scope.useRecoilState(MockAtoms.intState)
        obj.wrappedValue = 1
        
        XCTAssertEqual(mockSubscriber.changedNodeKey, MockAtoms.intState.key)
        XCTAssertEqual(mockSubscriber.nodeChangedCallCount, 2)
    }
    
    func test_should_release_node_unsubscribe_is_called() {
        let store = RecoilStore()
        let mockSubscriber = MockSubscriber()
        let nodeKey = MockAtoms.intState.key
        
        _ = store.safeGetLoadable(for: MockAtoms.intState)
        XCTAssertNotNil(store.getLoadable(for: nodeKey))
        
        let subscription = store.subscribe(for: nodeKey, subscriber: mockSubscriber)
        subscription.unsubscribe()
        XCTAssertNil(store.getLoadable(for: nodeKey))
    }
    
    func test_should_add_node_and_remove_node_in_graph_when_node_is_unsubscribe() {
        let store = RecoilStore()
        XCTAssertEqual(store.graph.allNodes().count, 0)
        
        // Add Node
        _ = store.safeGetLoadable(for: MockAtoms.intState)
        XCTAssertEqual(store.graph.allNodes().count, 1)
        
        // Remove Node
        let nodeKey = MockAtoms.intState.key
        let subscription = store.subscribe(for: nodeKey, subscriber: MockSubscriber())
        subscription.unsubscribe()
        XCTAssertEqual(store.graph.allNodes().count, 0)
    }

    func test_should_subscribe_when_subscribeIsCalled_given_validSubscriber() {
        let mockSubscriber = MockSubscriber()
        let _ = store.subscribe(subscriber: mockSubscriber)
        _ = scope.useRecoilState(MockAtoms.intState)
        XCTAssertEqual(mockSubscriber.storeChangedCallCount, 1)
    }
    
    func test_should_remove_store_subscriber_when_unsubscribe_is_called() {
        let store = RecoilStore()
        
        let subscription = store.subscribe(subscriber: MockSubscriber())
        XCTAssertEqual(store.storeSubscribers.count, 1)
        
        subscription.unsubscribe()
        XCTAssertEqual(store.storeSubscribers.count, 0)
    }
}

class MockSubscriber: Subscriber {
    private(set) var storeChangedCallCount = 0
    private(set) var nodeChangedCallCount = 0
    
    private(set) var changedNodeKey: NodeKey?
    
    func valueDidChange<T: RecoilNode>(node: T, newValue: NodeStatus<T.T>) {
        changedNodeKey = node.key
        nodeChangedCallCount += 1
    }
    
    func storeChange(snapshot: Snapshot) {
        storeChangedCallCount += 1
    }
}

