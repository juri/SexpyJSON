@testable import SexpyJSON
import XCTest

final class FnTests: XCTestCase {
    // ((fn ()))
    func testNoParametersNoExpressions() throws {
        let expr = Expression.call(
            .init(
                target: .call(
                    .init(
                        target: .symbol(Symbol("fn")),
                        params: [
                            .value(.null),
                        ]
                    )
                ),
                params: []
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .null)
    }

    // ((fn [a1 a2 a3] (+ a1 a2 a3)) 1 2 3)
    func testParametersAndExpression() throws {
        let expr = Expression.call(
            .init(
                target: .call(
                    .init(
                        target: .symbol(Symbol("fn")),
                        params: [
                            .value(.array([
                                .symbol(Symbol("a1")),
                                .symbol(Symbol("a2")),
                                .symbol(Symbol("a3")),
                            ])),

                            .call(.init(
                                target: .symbol(Symbol("+")),
                                params: [
                                    .symbol(Symbol("a1")),
                                    .symbol(Symbol("a2")),
                                    .symbol(Symbol("a3")),
                                ]
                            )),
                        ]
                    )
                ),
                params: [
                    .value(.number("1")),
                    .value(.number("2")),
                    .value(.number("3")),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 6.0, accuracy: 0.00001)
    }
}
