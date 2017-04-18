import XCTest

open class TestCase: XCTestCase {}

public func assert(
    _ expression: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTAssert(expression, message, file: file, line: line)
}

public func assertNil(
    _ expression: @autoclosure () throws -> Any?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTAssertNil(expression, message, file: file, line: line)
}

public func assertNotNil(
    _ expression: @autoclosure () throws -> Any?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTAssertNotNil(expression, message, file: file, line: line)
}

public func assertTrue(
    _ expression: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTAssertTrue(expression, message, file: file, line: line)
}

public func assertFalse(
    _ expression: @autoclosure () throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTAssertFalse(expression, message, file: file, line: line)
}

public func assertEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

public func assertEqual<T>(
    _ expression1: @autoclosure () throws -> T?,
    _ expression2: @autoclosure () throws -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

public func assertEqual<T>(
    _ expression1: @autoclosure () throws -> ArraySlice<T>,
    _ expression2: @autoclosure () throws -> ArraySlice<T>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

public func assertEqual<T>(
    _ expression1: @autoclosure () throws -> ContiguousArray<T>,
    _ expression2: @autoclosure () throws -> ContiguousArray<T>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

public func assertEqual<T>(
    _ expression1: @autoclosure () throws -> [T],
    _ expression2: @autoclosure () throws -> [T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

public func assertEqual<T, U>(
    _ expression1: @autoclosure () throws -> [T : U],
    _ expression2: @autoclosure () throws -> [T : U],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Hashable, U : Equatable {
    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
}

public func assertEqualWithAccuracy<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    accuracy: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : FloatingPoint {
    XCTAssertEqualWithAccuracy(
        expression1,
        expression2,
        accuracy: accuracy,
        message,
        file: file,
        line: line)
}

public func assertGreaterThan<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Comparable {
    XCTAssertGreaterThan(
        expression1,
        expression2,
        message,
        file: file,
        line: line)
}

public func assertGreaterThanOrEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Comparable {
    XCTAssertGreaterThanOrEqual(
        expression1,
        expression2,
        message,
        file: file,
        line: line)
}

public func assertLessThan<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Comparable {
    XCTAssertLessThan(expression1, expression2, message, file: file, line: line)
}

public func assertLessThanOrEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Comparable {
    XCTAssertLessThanOrEqual(
        expression1,
        expression2,
        message,
        file: file,
        line: line)
}

public func assertNotEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertNotEqual(expression1, expression2, message, file: file, line: line)
}

public func assertNotEqual<T>(
    _ expression1: @autoclosure () throws -> T?,
    _ expression2: @autoclosure () throws -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertNotEqual(expression1, expression2, message, file: file, line: line)
}

public func assertNotEqual<T>(
    _ expression1: @autoclosure () throws -> ArraySlice<T>,
    _ expression2: @autoclosure () throws -> ArraySlice<T>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertNotEqual(expression1, expression2, message, file: file, line: line)
}

public func assertNotEqual<T>(
    _ expression1: @autoclosure () throws -> ContiguousArray<T>,
    _ expression2: @autoclosure () throws -> ContiguousArray<T>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertNotEqual(expression1, expression2, message, file: file, line: line)
}

public func assertNotEqual<T>(
    _ expression1: @autoclosure () throws -> [T],
    _ expression2: @autoclosure () throws -> [T],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Equatable {
    XCTAssertNotEqual(expression1, expression2, message, file: file, line: line)
}

public func assertNotEqual<T, U>(
    _ expression1: @autoclosure () throws -> [T : U],
    _ expression2: @autoclosure () throws -> [T : U],
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : Hashable, U : Equatable {
    XCTAssertNotEqual(expression1, expression2, message, file: file, line: line)
}

public func assertNotEqualWithAccuracy<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    accuracy: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) where T : FloatingPoint {
    XCTAssertNotEqualWithAccuracy(
        expression1,
        expression2,
        accuracy,
        message,
        file: file,
        line: line)
}

public func assertThrowsError<T>(
    _ expression: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }) {
    XCTAssertThrowsError(
        expression,
        message(),
        file: file,
        line: line,
        errorHandler)
}

public func assertNoThrow<T>(
    _ expression: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTAssertNoThrow(expression, message, file: file, line: line)
}

public func fail(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) {
    XCTFail(message, file: file, line: line)
}
