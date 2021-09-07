@testable import SexpyJSON
import XCTest

final class DefineTests: XCTestCase {
    func testRecursiveFunction() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(Symbol("let")),
                params: [
                    .value(.null),
                    .call(
                        .init(
                            target: .symbol(Symbol("define")),
                            params: [
                                .symbol(Symbol("myfun")),
                                .call(
                                    .init(
                                        target: .symbol(Symbol("fn")),
                                        params: [
                                            .value(.array([
                                                .symbol(Symbol("p")),
                                            ])),

                                            .call(
                                                .init(
                                                    target: .symbol(Symbol("if")),
                                                    params: [
                                                        .call(
                                                            .init(
                                                                target: .symbol(Symbol("eq")),
                                                                params: [
                                                                    .symbol(Symbol("p")),
                                                                    .value(.string("aaaaa")),
                                                                ]
                                                            )
                                                        ),

                                                        .symbol(Symbol("p")),
                                                        .call(
                                                            .init(
                                                                target: .symbol(Symbol("myfun")),
                                                                params: [
                                                                    .call(
                                                                        .init(
                                                                            target: .symbol(Symbol("concat")),
                                                                            params: [
                                                                                .symbol(Symbol("p")),
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
                    .call(.init(target: .symbol(Symbol("myfun")), params: [.value(.string("a"))])),
                ]
            )
        )

        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(outputValue, .string("aaaaa"))
    }
}
