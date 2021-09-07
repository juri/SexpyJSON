@testable import SexpyJSON
import XCTest

final class ConcatTests: XCTestCase {
    func testNoParametersThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("concat")),
                params: []
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testOneParameterThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("concat")),
                params: [
                    .value(.string("a")),
                ]
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testTwoEmptyStringsMakesEmptyString() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("concat")),
                params: [
                    .value(.string("")),
                    .value(.string("")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.string), "")
    }

    func testTwoEmptyArraysMakesEmptyArray() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("concat")),
                params: [
                    .value(.array([])),
                    .value(.array([])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.array), [])
    }

    func testConcatThreeStrings() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("concat")),
                params: [
                    .value(.string("a")),
                    .value(.string("b")),
                    .value(.string("c")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.string), "abc")
    }

    func testConcatThreeArrays() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("concat")),
                params: [
                    .value(.array([.value(.string("X"))])),
                    .value(.array([.value(.string("Y"))])),
                    .value(.array([.value(.string("Z"))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.array), [.string("X"), .string("Y"), .string("Z")])
    }
}
