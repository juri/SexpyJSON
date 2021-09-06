@testable import SexpyJSON
import XCTest

final class FnTests: XCTestCase {
    // ((fn ()))
    func testNoParametersNoExpressions() throws {
        let expr = Expression.call(
            .init(
                target: .call(
                    .init(
                        target: .symbol(.name("fn")),
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
                        target: .symbol(.name("fn")),
                        params: [
                            .value(.array([
                                .symbol(.name("a1")),
                                .symbol(.name("a2")),
                                .symbol(.name("a3")),
                            ])),

                            .call(.init(
                                target: .symbol(.addition),
                                params: [
                                    .symbol(.name("a1")),
                                    .symbol(.name("a2")),
                                    .symbol(.name("a3")),
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
