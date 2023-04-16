import XCTest

@testable import RecoilSwift

enum TestError: String, Error {
    case unknown
    case param
    case someError
}

class RecoilErrorTests: XCTestCase {

    var circularInfo1: RecoilError.CircularInfo!
    var circularInfo2: RecoilError.CircularInfo!

    override func setUp() {
        super.setUp()
        circularInfo1 = RecoilError.CircularInfo(
            key: NodeKey("Key1"),
            deps: [NodeKey("DepKey1")]
        )
        
        circularInfo2 = RecoilError.CircularInfo(
            key: NodeKey("Key2"),
            deps: [NodeKey("DepKey2")]
        )
    }

    override func tearDown() {
        circularInfo1 = nil
        circularInfo2 = nil
        super.tearDown()
    }

    func test_should_returnTrue_when_compareErrors_given_twoUnknownErrors() {
        let error1 = RecoilError.unknown
        let error2 = RecoilError.unknown
        XCTAssertTrue(error1 == error2, "Expected two unknown RecoilErrors to be equal")
    }

    func test_should_returnTrue_when_compareErrors_given_twoCircularErrorsWithSameInfo() {
        let error1 = RecoilError.circular(circularInfo1)
        let error2 = RecoilError.circular(circularInfo1)
        XCTAssertTrue(error1 == error2, "Expected two circular RecoilErrors with same info to be equal")
    }

    func test_should_returnFalse_when_compareErrors_given_twoCircularErrorsWithDifferentInfo() {
        let error1 = RecoilError.circular(circularInfo1)
        let error2 = RecoilError.circular(circularInfo2)
        XCTAssertFalse(error1 == error2, "Expected two circular RecoilErrors with different info to be not equal")
    }

    func test_should_returnFalse_when_compareErrors_given_unknownAndCircularError() {
        let error1 = RecoilError.unknown
        let error2 = RecoilError.circular(circularInfo1)
        XCTAssertFalse(error1 == error2, "Expected unknown and circular RecoilErrors to be not equal")
    }
    
    func test_should_returnUnknownDescription_when_descriptionIsCalled_given_unknownError() {
        let error = RecoilError.unknown
        XCTAssertEqual(error.description, "RecoilError.unkown", "Expected description of unknown RecoilError to be 'RecoilError.unkown'")
    }

    func test_should_returnCircularDescription_when_descriptionIsCalled_given_circularError() {
        let error = RecoilError.circular(circularInfo1)
        XCTAssertEqual(error.description, circularInfo1.description, "Expected description of circular RecoilError to match CircularInfo's description")
    }

    func test_should_returnStackMessage_when_stackMessageIsCalled_given_circularInfo() {
        XCTAssertEqual(circularInfo1.stackMessaage, "DepKey1 -> Key1", "Expected correct stack message in CircularInfo")
    }

    func test_should_returnCorrectDescription_when_descriptionIsCalled_given_circularInfo() {
        XCTAssertEqual(circularInfo1.description, "RecoilError.Circular(deps: [DepKey1 -> Key1])", "Expected correct description in CircularInfo")
    }
}
