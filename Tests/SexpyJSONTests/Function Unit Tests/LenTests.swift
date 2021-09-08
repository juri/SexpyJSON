@testable import SexpyJSON
import XCTest

final class LenTests: XCTestCase {
    func testNoParamsThrows() throws {
        let expr = Expression.call(.init(target: .symbol(Symbol("len")), params: []))
        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testTwoParamsThrows() throws {
        let expr = Expression.call(.init(
            target: .symbol(Symbol("len")),
            params: [.value(.string("a")), .value(.string("b"))]
        ))
        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testNumberThrows() throws {
        let expr = Expression.call(.init(
            target: .symbol(Symbol("len")),
            params: [.value(.number("40"))]
        ))
        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testEmptyStringReturnsZero() throws {
        let expr = Expression.call(.init(
            target: .symbol(Symbol("len")),
            params: [.value(.string(""))]
        ))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 0.0, accuracy: 0.0001)
    }

    func testEmptyArrayReturnsZero() throws {
        let expr = Expression.call(.init(
            target: .symbol(Symbol("len")),
            params: [.value(.array([]))]
        ))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 0.0, accuracy: 0.0001)
    }

    func testStringReturnsLength() throws {
        let expr = Expression.call(.init(
            target: .symbol(Symbol("len")),
            params: [.value(.string("hello world"))]
        ))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 11.0, accuracy: 0.0001)
    }

    func testArrayReturnsLength() throws {
        let expr = Expression.call(.init(
            target: .symbol(Symbol("len")),
            params: [.value(.array([.value(.string("hello world"))]))]
        ))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 1.0, accuracy: 0.0001)
    }
}
