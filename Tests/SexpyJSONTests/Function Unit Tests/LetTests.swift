@testable import SexpyJSON
import XCTest

final class LetTests: XCTestCase {
    func testNullNoExpressions() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("let")),
                params: [
                    .value(.null),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .null)
    }

    func testNullBindings() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("let")),
                params: [
                    .value(.null),
                    .call(.init(target: .symbol(Symbol("+")), params: [
                        .value(.number("4")),
                        .value(.number("3")),
                    ])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 7, accuracy: 0.0001)
    }

    func testOneBoundValue() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("let")),
                params: [
                    .call(.init(expressions: [
                        .symbol(Symbol("foo")),
                        .value(.string("bar")),
                    ])),
                    .symbol(Symbol("foo")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .string("bar"))
    }

    func testMultipleBoundValues() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("let")),
                params: [
                    .call(.init(expressions: [
                        .symbol(Symbol("n1")),
                        .value(.string("foo")),
                        .symbol(Symbol("n2")),
                        .symbol(Symbol("n1")),
                        .symbol(Symbol("n3")),
                        .symbol(Symbol("n2")),
                    ])),
                    .symbol(Symbol("n3")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .string("foo"))
    }

    func testMultipleExpressions() throws {
        var extraFuncArgumentValue: String?
        let extraFunc = SpecialOperator(f: { args, context in
            XCTAssertEqual(args.count, 1)
            let arg = try XCTUnwrap(args.first)
            let argValue = try evaluate(expression: arg, in: &context)
            switch argValue {
            case let .string(s):
                extraFuncArgumentValue = s
            default:
                XCTFail("Unexpected argument value: \(argValue)")
            }
            return .string("this value is written over")
        })

        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("let")),
                params: [
                    .call(.init(expressions: [
                        .symbol(Symbol("n1")),
                        .value(.string("foo")),
                        .symbol(Symbol("n2")),
                        .symbol(Symbol("n1")),
                        .symbol(Symbol("ep1")),
                        .value(.string("bar")),
                        .symbol(Symbol("paramForExtraCall")),
                        .symbol(Symbol("ep1")),
                        .symbol(Symbol("n3")),
                        .symbol(Symbol("n2")),
                    ])),
                    .call(.init(target: .symbol(Symbol("extraFunc")), params: [.symbol(Symbol("paramForExtraCall"))])),
                    .symbol(Symbol("n3")),
                ]
            )
        )

        let context = Context.withBuiltins.wrap(names: [Symbol("extraFunc"): .callable(.specialOperator(extraFunc))])
        let outputValue = try evaluateToOutput(expression: expr, in: context)
        XCTAssertEqual(outputValue, .string("foo"))
        XCTAssertEqual(extraFuncArgumentValue, "bar")
    }
}
