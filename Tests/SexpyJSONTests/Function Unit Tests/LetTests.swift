@testable import SexpyJSON
import XCTest

final class LetTests: XCTestCase {
    func testNullNoExpressions() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(.name("let")),
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
                target: .symbol(.name("let")),
                params: [
                    .value(.null),
                    .call(.init(target: .symbol(.addition), params: [
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
                target: .symbol(.name("let")),
                params: [
                    .value(.array([
                        .symbol(.name("foo")),
                        .value(.string("bar")),
                    ])),
                    .symbol(.name("foo")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .string("bar"))
    }

    func testMultipleBoundValues() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(.name("let")),
                params: [
                    .value(.array([
                        .symbol(.name("n1")),
                        .value(.string("foo")),
                        .symbol(.name("n2")),
                        .symbol(.name("n1")),
                        .symbol(.name("n3")),
                        .symbol(.name("n2")),
                    ])),
                    .symbol(.name("n3")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .string("foo"))
    }

    func testMultipleExpressions() throws {
        var extraFuncArgumentValue: String?
        let extraFunc = Function(f: { args, context in
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
                target: .symbol(.name("let")),
                params: [
                    .value(.array([
                        .symbol(.name("n1")),
                        .value(.string("foo")),
                        .symbol(.name("n2")),
                        .symbol(.name("n1")),
                        .symbol(.name("ep1")),
                        .value(.string("bar")),
                        .symbol(.name("paramForExtraCall")),
                        .symbol(.name("ep1")),
                        .symbol(.name("n3")),
                        .symbol(.name("n2")),
                    ])),
                    .call(.init(target: .symbol(.name("extraFunc")), params: [.symbol(.name("paramForExtraCall"))])),
                    .symbol(.name("n3")),
                ]
            )
        )

        let context = Context.withBuiltins.wrap(names: [.name("extraFunc"): .function(extraFunc)])
        let outputValue = try evaluateToOutput(expression: expr, in: context)
        XCTAssertEqual(outputValue, .string("foo"))
        XCTAssertEqual(extraFuncArgumentValue, "bar")
    }
}
