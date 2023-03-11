import SwiftUI
import XCTest
import RecoilSwiftXCTests

@testable import RecoilSwift

final class NodeAccessorTests: XCTestCase {
    @RecoilTestScope var scope
    
    var accessor: StateAccessor {
        _scope.accessor(deps: [])
    }
    
    override func setUp() {
        _scope.reset()
    }
}

// MARK: - sync selector
extension NodeAccessorTests {
    func test_should_throwCircleError_when_get_selector_value_given_states_is_self_reference() throws {
        XCTAssertThrowsSpecificError(
            try accessor.get(CircleDeps.selfReferenceState),
            RecoilError.circular
        )
    }
    
    func test_should_throwCircleError_when_get_value_given_stateA_and_stateB_is_circular_reference() throws {
        XCTAssertThrowsSpecificError(
            try accessor.get(CircleDeps.stateA),
            RecoilError.circular
        )
    }
    
    func test_should_set_value_toAtom_when_call_set_method_for_syncNodes() throws {
        XCTAssertEqual(try accessor.get(MockAtoms.intState), 0)
        
        accessor.set(MockAtoms.intState, 12)
        
        XCTAssertEqual(try accessor.get(MockAtoms.intState), 12)
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
}
