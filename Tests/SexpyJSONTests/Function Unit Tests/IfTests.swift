@testable import SexpyJSON
import XCTest

final class IfTests: XCTestCase {
    func testNoParametersThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("if")),
                params: []
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testOneParameterThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("if")),
                params: [
                    .value(.boolean(true)),
                ]
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testTwoParametersThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("if")),
                params: [
                    .value(.boolean(true)),
                    .value(.string("then-branch")),
                ]
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testFourParametersThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("if")),
                params: [
                    .value(.boolean(true)),
                    .value(.string("then-branch")),
                    .value(.string("else-branch")),
                    .value(.string("this is extra")),
                ]
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testTrueReturnsFirstValue() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("if")),
                params: [
                    .value(.boolean(true)),
                    .value(.string("then-branch")),
                    .value(.string("else-branch")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.string), "then-branch")
    }

    func testFalseReturnsSecondValue() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("if")),
                params: [
                    .value(.boolean(false)),
                    .value(.string("then-branch")),
                    .value(.string("else-branch")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.string), "else-branch")
    }
}
