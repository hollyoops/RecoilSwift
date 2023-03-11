import XCTest

import RecoilSwiftXCTests
@testable import RecoilSwift

final class AtomAccessTests: XCTestCase {
    struct TestModule  {
        static var stringAtom: Atom<String> {
            atom { "rawValue" }
        }
    }
    
    @RecoilTestScope var scope
    
    override func setUp() {
        _scope.reset()
    }
    
    func test_should_atom_value_when_useRecoilValue_given_stringAtom() async {
        let view = ViewRenderHelper { ctx, sut in
            let value = ctx.useRecoilValue(TestModule.stringAtom)
            sut.expect(value).equalTo("rawValue")
        }
        
        await view.waitForRender()
    }
    
    func test_should_returnUpdatedValue_when_useRecoilState_given_stringAtom() {
        var value = scope.useRecoilState(TestModule.stringAtom)
        XCTAssertEqual(value.wrappedValue, "rawValue")
        
        value.wrappedValue = "newValue"
        
        let newValue = scope.useRecoilValue(TestModule.stringAtom)
        XCTAssertEqual(newValue, "newValue")
    }
    
    func test_should_refreshView_when_useRecoilState_given_after_stateChange() async throws {
        var value = scope.useRecoilState(TestModule.stringAtom)
        
        XCTAssertEqual(_scope.viewRefreshCount, 0)
        
        try await _scope.waitNextStateChange {
            value.wrappedValue = "newValue"
        }
        
        XCTAssertEqual(_scope.viewRefreshCount, 1)
    }
    
    func test_should_refreshView_when_useRecoilLoadable_given_after_stateChange() {
        let value = scope.useRecoilValueLoadable(TestModule.stringAtom)

        XCTAssertEqual(value.data, "rawValue")
    }
}
