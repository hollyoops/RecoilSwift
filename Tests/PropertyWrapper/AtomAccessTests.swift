import XCTest

import RecoilSwiftTestKit
@testable import RecoilSwift

final class AtomAccessTests: XCTestCase {
    struct TestModule  {
        static var stringAtom: Atom<String> {
            atom { "rawValue" }
        }
    }
    
 @RecoilTestScope var recoil
    
    override func setUp() {
        _recoil.reset()
    }
    
    func test_should_atom_value_when_useValue_given_stringAtom() async {
        let view = ViewRenderHelper { recoil, sut in
            let value = try? recoil.useThrowingValue(TestModule.stringAtom)
            sut.expect(value).equalTo("rawValue")
        }
        
        await view.waitForRender()
    }
    
    func test_should_returnUpdatedValue_when_useThrowingBinding_given_stringAtom() throws {
        var binding = recoil.useThrowingBinding(TestModule.stringAtom)
        XCTAssertEqual(try binding.wrappedValue, "rawValue")
        XCTAssertEqual(binding.value, "rawValue")
        XCTAssertEqual(binding.unsafeValue, "rawValue")
        
        binding.value = "newValue"
        
        let newValue = try recoil.useThrowingValue(TestModule.stringAtom)
        XCTAssertEqual(newValue, "newValue")
    }
    
    func test_should_returnUpdatedValue_when_useUnsafeBinding_given_stringAtom() throws {
        let binding = recoil.useUnsafeBinding(TestModule.stringAtom)
        XCTAssertEqual(binding.wrappedValue, "rawValue")
        
        binding.wrappedValue = "newValue"
        
        let newValue = recoil.useUnsafeValue(TestModule.stringAtom)
        XCTAssertEqual(newValue, "newValue")
    }
    
    func test_should_returnUpdatedValue_when_useBinding_given_stringAtom() throws {
        let value = recoil.useBinding(TestModule.stringAtom)
        XCTAssertEqual(value.wrappedValue, "rawValue")
        
        value.wrappedValue = "newValue"
        
        let newValue = try recoil.useThrowingValue(TestModule.stringAtom)
        XCTAssertEqual(newValue, "newValue")
    }
    
    func test_should_refreshView_when_useBinding_given_after_stateChange() async throws {
        let value = recoil.useBinding(TestModule.stringAtom)
        
        XCTAssertEqual(_recoil.viewRefreshCount, 1)
        
        try await _recoil.waitNextStateChange {
            value.wrappedValue = "newValue"
        }
        
        XCTAssertEqual(_recoil.viewRefreshCount, 2)
    }
    
    func test_should_refreshView_when_useLoadable_given_after_stateChange() {
        let value = recoil.useLoadable(TestModule.stringAtom)

        XCTAssertEqual(value.data, "rawValue")
    }
}
