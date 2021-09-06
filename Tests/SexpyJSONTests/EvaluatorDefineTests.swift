@testable import SexpyJSON
import XCTest

final class EvaluatorDefineTests: XCTestCase {
    func testRecursiveFunction() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(.name("let")),
                params: [
                    .value(.null),
                    .call(
                        .init(
                            target: .symbol(.name("define")),
                            params: [
                                .symbol(.name("myfun")),
                                .call(
                                    .init(
                                        target: .symbol(.name("fn")),
                                        params: [
                                            .value(.array([
                                                .symbol(.name("p")),
                                            ])),

                                            .call(
                                                .init(
                                                    target: .symbol(.name("if")),
                                                    params: [
                                                        .call(
                                                            .init(
                                                                target: .symbol(.name("eq")),
                                                                params: [
                                                                    .symbol(.name("p")),
                                                                    .value(.string("aaaaa")),
                                                                ]
                                                            )
                                                        ),

                                                        .symbol(.name("p")),
                                                        .call(
                                                            .init(
                                                                target: .symbol(.name("myfun")),
                                                                params: [
                                                                    .call(
                                                                        .init(
                                                                            target: .symbol(.name("concat")),
                                                                            params: [
                                                                                .symbol(.name("p")),
                                                                                .value(.string("a")),
                                                                            ]
                                                                        )
                                                                    ),
                                                                ]
                                                            )
                                                        ),
                                                    ]
                                                )
                                            ),
                                        ]
                                    )
                                ),
                            ]
                        )
                    ),
                    .call(.init(target: .symbol(.name("myfun")), params: [.value(.string("a"))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .string("aaaaa"))
    }
}
