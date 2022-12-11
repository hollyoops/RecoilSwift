import SwiftUI
import XCTest

@testable import RecoilSwift

final class SelectorReadWriteTests: XCTestCase {
  struct TestModule  {
    static var namesState = atom { ["", "Ella", "Chris", "", "Paul"] }
    static let filteredNamesState = selector { get -> [String] in
      get(namesState).filter { $0 != ""}
    }
    
    static let tempFahrenheitState: Atom<Int> = atom(32)
    static let tempCelsiusSelector: MutableSelector<Int> = selector(
      get: { get in
        let fahrenheit = get(tempFahrenheitState)
        return (fahrenheit - 32) * 5 / 9
      },
      set: { context, newValue in
        let newFahrenheit = (newValue * 9) / 5 + 32
        context.set(tempFahrenheitState, newFahrenheit)
      }
    )
  }
  
  var getter: Getter!
  override func setUp() {
    RecoilStore.shared.reset()
    getter = NodeAccessor(store: RecoilStore.shared).getter()
    TestModule.namesState = atom { ["", "Ella", "Chris", "", "Paul"] }
  }
}

// MARK: - sync selector
extension SelectorReadWriteTests {
  func testFilterSelector() {
    let tester = HookTester {
      useRecoilValue(TestModule.filteredNamesState)
    }
    
    XCTAssertEqual(tester.value, ["Ella", "Chris", "Paul"])
  }
  
  func testWritableSelector() {
    let tester = HookTester {
      useRecoilState(TestModule.tempCelsiusSelector)
    }
    
    XCTAssertEqual(tester.value.wrappedValue, 0)
    
    tester.value.wrappedValue = 30
    
    XCTAssertEqual(getter(TestModule.tempFahrenheitState), 86)
    XCTAssertEqual(tester.value.wrappedValue, 30)
  }
}
