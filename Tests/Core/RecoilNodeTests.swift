import XCTest
@testable import RecoilSwift

class RecoilNodeTests: XCTestCase {
    func test_should_returnCorrectKey_when_keyIsCalled_given_CustomerRecoilNode() {
        let node = TempFahrenheitState()
        let key = node.key
        XCTAssertEqual(key.name, "TempFahrenheitState")
    }
    
    func test_should_returnCorrectKey_when_keyIsCalled_given_ScopedRecoilNode() {
        let key = RemoteNames.names.key
        XCTAssertEqual(key.name,
                       "names",
                       "Expected NodeKey name to match RecoilNode type when constructed with RecoilNode")
    }
}
