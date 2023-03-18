import SwiftUI
import XCTest
import RecoilSwiftXCTests

@testable import RecoilSwift

struct ErrorDeps {
    typealias Selector = RecoilSwift.Selector
    
    static var stateA: Selector<String> {
        selector { context in
            try context.get(stateB)
        }
    }
    
    static var stateB: Selector<String> {
        selector { context in
            try context.get(ErrorState(error: MyError.unknown))
        }
    }

    static var selfErrorState: Selector<String> {
        selector { context in throw MyError.param }
    }
}

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
        let info = RecoilError.CircularInfo(key: CircleDeps.selfReferenceState.key,
                                            deps: [CircleDeps.selfReferenceState.key])
        
        XCTAssertThrowsSpecificError(
            try accessor.get(CircleDeps.selfReferenceState),
            RecoilError.circular(info)
        )

        XCTAssertEqual(info.stackMessaage, "selfReferenceState -> selfReferenceState")
    }
    
    func test_should_throwCircleError_when_get_value_given_stateA_and_stateB_is_circular_reference() throws {
        let info = RecoilError.CircularInfo(
            key: CircleDeps.stateA.key,
            deps: [CircleDeps.stateA.key, CircleDeps.stateB.key]
        )
        
        XCTAssertThrowsSpecificError(
            try accessor.get(CircleDeps.stateA),
            RecoilError.circular(info)
        )

        XCTAssertEqual(info.stackMessaage, "stateA -> stateB -> stateA")
    }
    
    func test_should_set_value_toAtom_when_call_set_method_for_syncNodes() throws {
        XCTAssertEqual(try accessor.get(MockAtoms.intState), 0)
        
        accessor.set(MockAtoms.intState, 12)
        
        XCTAssertEqual(try accessor.get(MockAtoms.intState), 12)
    }
    
    func test_should_get_error_when_get_value_given_self_states_hasError() throws {
        XCTAssertThrowsSpecificError(
            try accessor.get(ErrorDeps.selfErrorState),
            MyError.param
        )
    }
    
    func test_should_return_upstream_error_when_get_value_given_upstream_states_hasError() throws {
        XCTAssertThrowsSpecificError(
            try accessor.get(ErrorDeps.stateA),
            MyError.unknown
        )
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
