import XCTest

@testable import RecoilSwift

final class AtomAccessTests: XCTestCase {
    struct TestModule  {
        static var stringAtom: Atom<String>!
//        static var remoteDataSource: AsyncAtom<[String]>!
//        static var remoteDataSourceError: AsyncAtom<[String]>!
    }
    
    @RecoilTestScope var scope
    
    override func setUp() {
        _scope.reset()
        
        TestModule.stringAtom = atom { "rawValue" }
//        TestModule.remoteDataSource = makeAsyncAtom(value: ["Book1", "Book2"])
//        TestModule.remoteDataSourceError = makeAsyncAtom(error: MyError.param, type: [String].self)
    }
    
    func test_should_atom_value_when_useRecoilValue_given_stringAtom() {
        let currentValue = scope.useRecoilValue(TestModule.stringAtom)
        XCTAssertEqual(currentValue, "rawValue")
    }
    
    func test_should_returnUpdatedValue_when_useRecoilState_given_stringAtom() {
        var value = scope.useRecoilState(TestModule.stringAtom)
        XCTAssertEqual(value.wrappedValue, "rawValue")
        
        value.wrappedValue = "newValue"
        
        let newValue = scope.useRecoilValue(TestModule.stringAtom)
        XCTAssertEqual(newValue, "newValue")
    }
    
//    func test_should_refreshView_when_useRecoilState_given_after_stateChange() async throws {
//        let expectation = XCTestExpectation(description: "should refresh when value changed")
//        var value = scope.useRecoilState(TestModule.stringAtom)
//        
//        XCTAssertEqual(_scope.viewRefreshCount, 0)
//        
//        value.wrappedValue = "newValue"
//        
//        try await scope.waitForViewRefresh()
//        
////        wait(for: [expectation], timeout: TestConfig.expectation_wait_seconds)
//        XCTAssertEqual(_scope.viewRefreshCount, 1)
//    }
    
    func test_should_refreshView_when_useRecoilLoadable_given_after_stateChange() {
        let value = scope.useRecoilValueLoadable(TestModule.stringAtom)

        XCTAssertEqual(value.data, "rawValue")
    }
}
