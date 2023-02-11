import SwiftUI
import XCTest

@testable import RecoilSwift

final class AtomReadWriteTests: XCTestCase {
    struct TestModule  {
        static var stringAtom = atom { "rawValue" }
    }
    
    @MainActor
    override func setUp() {
        RecoilTest.shared.reset()
    }
    
    func test_should_return_rawValue_when_read_only_atom_given_stringAtom() {
        let tester = HookTester {
            useRecoilValue(TestModule.stringAtom)
        }
        
        XCTAssertEqual(tester.value, "rawValue")
    }
    
    func test_should_return_newValue_when_read_write_atom_given_stringAtom_and_newValue() {
        let tester = HookTester {
            useRecoilState(TestModule.stringAtom)
        }
        
        XCTAssertEqual(tester.value.wrappedValue, "rawValue")
        
        tester.value.wrappedValue = "newValue"
        
        XCTAssertEqual(tester.value.wrappedValue, "newValue")
    }
}
