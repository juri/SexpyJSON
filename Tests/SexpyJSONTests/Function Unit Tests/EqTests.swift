@testable import SexpyJSON
import XCTest

final class EqTests: XCTestCase {
    func testNoParametersThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: []
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testOneParameterThrows() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.boolean(true)),
                ]
            )
        )

        XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
    }

    func testTwoBooleansEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.boolean(true)),
                    .value(.boolean(true)),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testFourBooleansEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.boolean(false)),
                    .value(.boolean(false)),
                    .value(.boolean(false)),
                    .value(.boolean(false)),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testFourBooleansEqualDontEqualIfOneIsDifferent() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.boolean(false)),
                    .value(.boolean(false)),
                    .value(.boolean(true)),
                    .value(.boolean(false)),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }

    func testTwoStringsEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.string("hello")),
                    .value(.string("hello")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testThreeStringsEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.string("hello")),
                    .value(.string("hello")),
                    .value(.string("hello")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testThreeStringsDontEqualIfOneIsDifferent() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.string("hello")),
                    .value(.string("hello")),
                    .value(.string("world")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }

    func testEmptyArraysEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.array([])),
                    .value(.array([])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testThreeArraysEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testThreeArraysDontEqualIfOneIsDifferent() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                    .value(.array([.value(.string("A")), .value(.string("b"))])),
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }

    func testThreeArraysDontEqualIfOneHasMoreElements() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                    .value(.array([.value(.string("a")), .value(.string("b"))])),
                    .value(.array([.value(.string("a")), .value(.string("b")), .value(.string("c"))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }

    func testEmptyObjectsEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.object([])),
                    .value(.object([])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testObjectsEqualIfAllFieldsAreSame() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.object([.init(name: "f1", value: .value(.string("v1")))])),
                    .value(.object([.init(name: "f1", value: .value(.string("v1")))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testObjectsDontEqualIfAllFieldsAreNotSame() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.object([.init(name: "f1", value: .value(.string("v1")))])),
                    .value(.object([.init(name: "f1", value: .value(.string("v2")))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }

    func testObjectsEqualIfNumberOfFieldsDoesntMatch() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.object([.init(name: "f1", value: .value(.string("v1")))])),
                    .value(.object([
                        .init(name: "f1", value: .value(.string("v1"))),
                        .init(name: "f2", value: .value(.string("v2"))),
                    ])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }

    func testComplicatedObjectsEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.object([
                        .init(name: "f1", value: .value(.array([
                            .value(.string("e1")),
                            .value(.string("e2")),
                            .value(.object([
                                .init(name: "ff1", value: .value(.string("vv1"))),
                            ])),
                        ]))),
                    ])),
                    .value(.object([
                        .init(name: "f1", value: .value(.array([
                            .value(.string("e1")),
                            .value(.string("e2")),
                            .value(.object([
                                .init(name: "ff1", value: .value(.string("vv1"))),
                            ])),
                        ]))),
                    ])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), true)
    }

    func testComplicatedObjectsDontEqual() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("eq")),
                params: [
                    .value(.object([
                        .init(name: "f1", value: .value(.array([
                            .value(.string("e1")),
                            .value(.string("e2")),
                            .value(.object([
                                .init(name: "ff1", value: .value(.string("vv1"))),
                            ])),
                        ]))),
                    ])),
                    .value(.object([
                        .init(name: "f1", value: .value(.array([
                            .value(.string("e1")),
                            .value(.string("e2")),
                            .value(.object([
                                .init(name: "ff1", value: .value(.string("VV1"))),
                            ])),
                        ]))),
                    ])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.boolean), false)
    }
}
