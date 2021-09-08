@testable import SexpyJSON
import XCTest

final class MathTests: XCTestCase {
    // MARK: Add

    func testAddOneNumber() throws {
        let expr = Expression.call(.init(target: .symbol(Symbol("+")), params: [.value(.number("-68"))]))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -68.0, accuracy: 0.0001)
    }

    func testAddTwoNumbers() throws {
        let expr = Expression.call(
            .init(target: .symbol(Symbol("+")), params: [.value(.number("1")), .value(.number("2"))])
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 3.0, accuracy: 0.0001)
    }

    func testAddThreeNumbers() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("+")),
                params: [.value(.number("1")), .value(.number("2")), .value(.number("-4"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -1.0, accuracy: 0.0001)
    }

    func testAddAdd() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("+")),
                params: [
                    .value(.number("1")),
                    .call(.init(target: .symbol(Symbol("+")), params: [
                        .value(.number("11")),
                        .value(.number("12")),
                    ])),
                    .value(.number("-4")),
                ]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 20.0, accuracy: 0.0001)
    }

    // MARK: Subtract

    func testSubtractOneNumber() throws {
        let expr = Expression.call(.init(target: .symbol(Symbol("-")), params: [.value(.number("-68"))]))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -68.0, accuracy: 0.0001)
    }

    func testSubtractTwoNumbers() throws {
        let expr = Expression.call(
            .init(target: .symbol(Symbol("-")), params: [.value(.number("1")), .value(.number("2"))])
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -1.0, accuracy: 0.0001)
    }

    func testSubtractThreeNumbers() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("-")),
                params: [.value(.number("1")), .value(.number("2")), .value(.number("-4"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 3.0, accuracy: 0.0001)
    }

    func testSubtract() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("-")),
                params: [
                    .value(.number("1")),
                    .call(.init(target: .symbol(Symbol("-")), params: [
                        .value(.number("11")),
                        .value(.number("12")),
                    ])),
                    .value(.number("-4")),
                ]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 6.0, accuracy: 0.0001)
    }

    // MARK: Multiply

    func testMultiplyOneNumber() throws {
        let expr = Expression.call(.init(target: .symbol(Symbol("*")), params: [.value(.number("-68"))]))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -68.0, accuracy: 0.0001)
    }

    func testMultiplyTwoNumbers() throws {
        let expr = Expression.call(
            .init(target: .symbol(Symbol("*")), params: [.value(.number("1")), .value(.number("2"))])
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 2.0, accuracy: 0.0001)
    }

    func testMultiplyThreeNumbers() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("*")),
                params: [.value(.number("1")), .value(.number("2")), .value(.number("-4"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -8.0, accuracy: 0.0001)
    }

    func testMultiplyMultiply() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("*")),
                params: [
                    .value(.number("1")),
                    .call(.init(target: .symbol(Symbol("*")), params: [
                        .value(.number("11")),
                        .value(.number("12")),
                    ])),
                    .value(.number("-4")),
                ]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -528.0, accuracy: 0.0001)
    }

    // MARK: Divide

    func testDivideOneNumber() throws {
        let expr = Expression.call(.init(target: .symbol(Symbol("/")), params: [.value(.number("-68"))]))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -68.0, accuracy: 0.0001)
    }

    func testDivideTwoIntegers() throws {
        let expr = Expression.call(
            .init(target: .symbol(Symbol("/")), params: [.value(.number("6")), .value(.number("2"))])
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 3.0, accuracy: 0.0001)
    }

    func testDivideByZero() throws {
        let expr = Expression.call(
            .init(target: .symbol(Symbol("/")), params: [.value(.number("6")), .value(.number("0"))])
        )
        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testDivideTwoDoubles() throws {
        let expr = Expression.call(
            .init(target: .symbol(Symbol("/")), params: [.value(.number("1.0")), .value(.number("2.0"))])
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 0.5, accuracy: 0.0001)
    }

    func testDivideThreeIntegers() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("/")),
                params: [.value(.number("20")), .value(.number("5")), .value(.number("-2"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -2.0, accuracy: 0.0001)
    }

    func testDivideThreeDoubles() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("/")),
                params: [.value(.number("1.0")), .value(.number("2.0")), .value(.number("-4.0"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -0.125, accuracy: 0.0001)
    }

    func testDivideThreeMixedValues() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("/")),
                params: [.value(.number("1.0")), .value(.number("2")), .value(.number("-4.0"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -0.125, accuracy: 0.0001)
    }

    func testDivideDivide() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("/")),
                params: [
                    .value(.number("1")),
                    .call(.init(target: .symbol(Symbol("/")), params: [
                        .value(.number("11.0")),
                        .value(.number("12")),
                    ])),
                    .value(.number("-4")),
                ]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -0.27272727, accuracy: 0.0001)
    }
}
