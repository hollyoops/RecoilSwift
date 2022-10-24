import SwiftUI
import XCTest
import Combine

@testable import RecoilSwift

final class CombineGetBodyTests: XCTestCase {
    
    func testShouldCallSuccess() async throws {
        let body = CombineGetBody {
            MockAPI.makeCombine(result: .success("Success"), delay: TestConfig.mock_async_wait_seconds)
        }
        
        let val = try await body.evaluate()
        XCTAssertEqual(val, "Success")
    }
    
    func testShouldCallFailedAndFinallyWhenThrowAnError() async throws {
        let body: CombineGetBody<String, Error> = CombineGetBody {
            throw MyError.param
        }

        do {
            _ = try await body.evaluate()
            throw MyError.unknown
        } catch {
            XCTAssertEqual(error as? MyError, MyError.param)
        }
    }

    func testShouldCallFailedAndFinallyWhenAPIError() async throws {
        let body: CombineGetBody<String, Error> = CombineGetBody {
            MockAPI.makeCombine(result: .failure(MyError.param), delay: TestConfig.mock_async_wait_seconds)
        }

        do {
            _ = try await body.evaluate()
            throw MyError.unknown
        } catch {
            XCTAssertEqual(error as? MyError, MyError.param)
        }
    }
}
