import XCTest

public func XCTAssertThrowsSpecificError<ReturnValue, ExpectedError>(
    file: StaticString = #file,
    line: UInt = #line,
    _ codeThatThrows: @autoclosure () throws -> ReturnValue,
    _ error: ExpectedError,
    _ message: String = ""
) where ExpectedError: Swift.Error & Equatable {
    
    XCTAssertThrowsError(try codeThatThrows(), message, file: file, line: line) { someError in
        guard let expectedErrorType = someError as? ExpectedError else {
            XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
            return
        }
        XCTAssertEqual(expectedErrorType, error, line: line)
    }
}

public func XCTAssertThrowsSpecificError<ExpectedError>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ error: ExpectedError,
    _ message: String = ""
) where ExpectedError: Swift.Error & Equatable {
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        guard let expectedErrorType = someError as? ExpectedError else {
            XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
            return
        }
        XCTAssertEqual(expectedErrorType, error)
    }
}

public func XCTAssertThrowsSpecificErrorType<Error>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ errorType: Error.Type,
    _ message: String = ""
) where Error: Swift.Error & Equatable {
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        XCTAssertTrue(someError is Error, "Expected code to throw error of type: <\(Error.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
    }
}

