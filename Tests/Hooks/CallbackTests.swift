import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

extension XCTestCase {
    func wait(timeInSeconds: TimeInterval = TestConfig.mock_async_wait_seconds) {
        let expectation = XCTestExpectation(description: "Wait")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInSeconds + 0.01) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeInSeconds + 0.1)
    }
}

final class CallbackTests: XCTestCase {
    @RecoilTestScope var recoil
    
    struct TestModule  {
        static var numberState: Atom<Int> {
            atom { 2 }
        }
        
        static func add(context: RecoilCallbackContext, number: Int) -> Int {
            let num = context.accessor.getUnsafe(numberState)
            let final = number + num
            context.accessor.set(numberState, final)
            return final
        }
        
        static func addThenMultiple(context: RecoilCallbackContext, number: Int, multiple: Int) -> Int {
            let num = context.accessor.getUnsafe(numberState)
            let final = (number + num) * multiple
            context.accessor.set(numberState, final)
            return final
        }
        
        static func addByRemote(context: RecoilCallbackContext) {
            func fetchRemoteNumber() -> AnyPublisher<Int, Error> {
                MockAPI.makeCombine(result: .success(1000))
            }
            let num = context.accessor.getUnsafe(numberState)
            fetchRemoteNumber()
                .sink(receiveCompletion: { _ in },
                      receiveValue: { context.accessor.set(numberState, $0 + num) })
                .store(in: context)
        }
        
        static func square(context: RecoilCallbackContext) {
            let num = context.accessor.getUnsafe(numberState)
            context.accessor.set(numberState, num * num)
        }
    }
    
    var accessor: StateAccessor {
        _recoil.accessor(deps: [])
    }
    
    override func setUp() {
        _recoil.reset()
    }
}

// MARK: - Sync
extension CallbackTests {
    func test_should_return12_when_add_given_number10() {
        let tester = HookTester(scope: _recoil) {
            useRecoilCallback(TestModule.add(context:number:))
        }
        
        let value = tester.value(10)
        
        XCTAssertEqual(value, 12)
        XCTAssertEqual(accessor.getUnsafe(TestModule.numberState), 12)
    }
    
    func test_should_return60_when_addThenMultiple_given_number10_and_multiple5() {
        let tester = HookTester(scope: _recoil) {
            useRecoilCallback(TestModule.addThenMultiple(context:number:multiple:))
        }
        
        let value = tester.value(10, 5)
        
        XCTAssertEqual(value, 60)
        XCTAssertEqual(accessor.getUnsafe(TestModule.numberState), 60)
    }
    
    func test_should_return16_when_square_given_twice_invocation() {
        let tester = HookTester(scope: _recoil) {
            useRecoilCallback(TestModule.square(context:))
        }
        
        tester.value()
        tester.value()
        
        XCTAssertEqual(accessor.getUnsafe(TestModule.numberState), 16)
    }
}

// MARK: - Async
extension CallbackTests {
    func test_should_return1002_when_addByRemote_given_wait_half_second() {
        let tester = HookTester(scope: _recoil) {
            useRecoilCallback(TestModule.addByRemote)
        }
        
        tester.value()
        XCTAssertEqual(accessor.getUnsafe(TestModule.numberState), 2)
        
        wait()
        
        XCTAssertEqual(accessor.getUnsafe(TestModule.numberState), 1002)
    }
}
