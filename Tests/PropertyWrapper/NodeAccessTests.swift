import SwiftUI
import XCTest
import RecoilSwiftTestKit

@testable import RecoilSwift

final class NodeAccessorTests: XCTestCase {
    @RecoilTestScope var recoil
    
    var accessor: StateAccessor {
        _recoil.accessor(deps: [])
    }
    
    override func setUp() {
        _recoil.purge()
    }
}

// MARK: - sync selector
extension NodeAccessorTests {
    func test_should_throwCircleError_when_get_selector_value_given_states_is_self_reference() throws {
        let info = RecoilError.CircularInfo(key: CircleRef.selfReferenceState.key,
                                            deps: [CircleRef.selfReferenceState.key])
        
        XCTAssertThrowsSpecificError(
            try accessor.get(CircleRef.selfReferenceState),
            RecoilError.circular(info)
        )

        XCTAssertEqual(info.stackMessaage, "selfReferenceState -> selfReferenceState")
    }
    
    func test_should_throwCircleError_when_get_value_given_stateA_and_stateB_is_circular_reference() throws {
        let info = RecoilError.CircularInfo(
            key: CircleRef.stateA.key,
            deps: [CircleRef.stateA.key, CircleRef.stateB.key]
        )
        
        XCTAssertThrowsSpecificError(
            try accessor.get(CircleRef.stateA),
            RecoilError.circular(info)
        )

        XCTAssertEqual(info.stackMessaage, "stateA -> stateB -> stateA")
    }
    
    func test_should_set_value_toAtom_when_call_set_method_for_syncNodes() throws {
        let state = MockAtom(value: 0)
        
        XCTAssertEqual(try accessor.get(state), 0)
        
        accessor.set(state, 12)
        
        XCTAssertEqual(try accessor.get(state), 12)
    }
    
    func test_should_returnLatestValue_when_call_get_value_given_dependency_of_dependency_hasChanged() throws {
        XCTAssertEqual(try accessor.get(MultipleTen.state), 0)
        
        accessor.set(MultipleTen.upstreamState, 12)
        
        XCTAssertEqual(try accessor.get(MultipleTen.state), 120)
    }
    
    func test_should_return_upstream_error_when_get_value_given_upstream_states_hasError() throws {
        _recoil.stubState(node: MultipleTen.state, error: TestError.param)
        XCTAssertThrowsSpecificError(try accessor.get(MultipleTen.state), TestError.param)
    }
    
    func test_should_return_upstream_value_when_get_value_given_upstream_stateError_map_to_value() throws {
        _recoil.stubState(node: MultipleTen.upstreamState, value: 20)
        XCTAssertEqual(try accessor.get(MultipleTen.state), 200)
    }
}

// MARK: - async selector
extension NodeAccessorTests {
    func test_should_returnFilterEmptyString_when_get_value_given_stateB_contains_empty_string() async throws {
        let values = try await accessor.get(RemoteNames.filteredNames)
        XCTAssertEqual(values, ["Ella", "Chris", "Paul"])
    }
    
    func test_should_returnNil_by_default_when_get_value_given_async_state() {
        let values = accessor.getOrNil(RemoteNames.filteredNames)
        XCTAssertNil(values)
    }
    
    func test_should_get_error_when_get_atomValue_given_self_states_hasError() async throws {
        do {
            _ = try await accessor.get(MockAsyncAtom<String>(error: TestError.param))
            XCTFail("should throw error")
        } catch {
            XCTAssertEqual(error as? TestError, TestError.param)
        }
    }
    
    func test_should_get_error_when_get_selectorValue_given_self_states_hasError() async throws {
        do {
            _ = try await accessor.get(MockAsyncSelector<String>(error: TestError.param))
            XCTFail("should throw error")
        } catch {
            XCTAssertEqual(error as? TestError, TestError.param)
        }
    }
    
    func test_should_returnTrueAnd_by_default_when_get_loading_from_node_given_async_state_inited_in_store() throws {
        let node = RemoteNames.filteredNames
        let _ = accessor.getOrNil(node)
        XCTAssertTrue(try accessor.getLoadingStatus(node))
        XCTAssertTrue(NodeAccessor(store: _recoil.store).getLoadingStatus(for:node.key))
    }
    
    func test_should_returnFalse_by_default_when_get_loading_given_async_state_not_init_in_store() {
        let node = RemoteNames.filteredNames
        XCTAssertFalse(try accessor.getLoadingStatus(node))
        XCTAssertFalse(NodeAccessor(store: _recoil.store).getLoadingStatus(for: node.key))
    }
    
    func test_should_return_upstream_asyncError_when_get_value_given_upstream_states_hasError() async throws {
        _recoil.stubState(node: AsyncMultipleTen.upstreamState, error: TestError.param)
        
        do {
            _ = try await accessor.get(AsyncMultipleTen.state)
            XCTFail("should throw error")
        } catch {
            XCTAssertEqual(error as? TestError, TestError.param)
        }
    }
    
    func test_should_return_upstream_asyncValue_when_get_value_given_upstream_stateError_map_to_value() async throws {
        _recoil.stubState(node: AsyncMultipleTen.upstreamState, value: 20)
        let value = try await accessor.get(AsyncMultipleTen.state)
        XCTAssertEqual(value, 200)
    }
}
