@testable import SexpyJSON
import XCTest

final class CompareTests: XCTestCase {
    func testNoParamsThrows() throws {
        for symbol in [">", ">=", "<", "<="] {
            let expr = Expression.call(.init(target: .symbol(Symbol(symbol)), params: []))
            XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
        }
    }

    func testOneParamsThrows() throws {
        for symbol in [">", ">=", "<", "<="] {
            let expr = Expression.call(.init(target: .symbol(Symbol(symbol)), params: [.value(.number("1"))]))
            XCTAssertThrowsError(try evaluateToOutput(expression: expr, in: .withBuiltins))
        }
    }

    func testNumberComparisons() throws {
        struct Case {
            let symbol: String
            let params: [String]
            let result: Bool

            let file: StaticString
            let line: UInt
        }

        func makeCase(_ symbol: String, params: [String], result: Bool, file: StaticString = #filePath, line: UInt = #line) -> Case {
            Case(symbol: symbol, params: params, result: result, file: file, line: line)
        }

        let cases: [Case] = [
            makeCase("<", params: ["1", "2"], result: true),
            makeCase("<", params: ["1.0", "2"], result: true),
            makeCase("<", params: ["1", "2.0"], result: true),
            makeCase("<", params: ["1.0", "2.0"], result: true),
            makeCase("<", params: ["1", "2", "3"], result: true),
            makeCase("<", params: ["1.0", "2.0", "3.0"], result: true),
            makeCase("<", params: ["1.0", "2", "3.0"], result: true),

            makeCase("<", params: ["2", "1"], result: false),
            makeCase("<", params: ["2.0", "1"], result: false),
            makeCase("<", params: ["2", "1.0"], result: false),
            makeCase("<", params: ["2.0", "1.0"], result: false),
            makeCase("<", params: ["3", "2", "1"], result: false),
            makeCase("<", params: ["3.0", "2.0", "1.0"], result: false),
            makeCase("<", params: ["3.0", "2", "1.0"], result: false),

            makeCase("<", params: ["1", "2", "1"], result: false),
            makeCase("<", params: ["1.0", "2.0", "1.0"], result: false),
            makeCase("<", params: ["1.0", "2", "1.0"], result: false),

            makeCase("<", params: ["3", "2", "3"], result: false),
            makeCase("<", params: ["3.0", "2.0", "3.0"], result: false),
            makeCase("<", params: ["3.0", "2", "3.0"], result: false),

            makeCase("<=", params: ["1", "2"], result: true),
            makeCase("<=", params: ["1.0", "2"], result: true),
            makeCase("<=", params: ["1", "2.0"], result: true),
            makeCase("<=", params: ["1.0", "2.0"], result: true),
            makeCase("<=", params: ["1", "2", "3"], result: true),
            makeCase("<=", params: ["1.0", "2.0", "3.0"], result: true),
            makeCase("<=", params: ["1.0", "2", "3.0"], result: true),

            makeCase("<=", params: ["1", "1"], result: true),
            makeCase("<=", params: ["1.0", "1"], result: true),
            makeCase("<=", params: ["1", "1.0"], result: true),
            makeCase("<=", params: ["1.0", "1.0"], result: true),
            makeCase("<=", params: ["1", "1", "1"], result: true),
            makeCase("<=", params: ["1.0", "1.0", "1.0"], result: true),
            makeCase("<=", params: ["1.0", "1", "1.0"], result: true),

            makeCase("<=", params: ["2", "1"], result: false),
            makeCase("<=", params: ["2.0", "1"], result: false),
            makeCase("<=", params: ["2", "1.0"], result: false),
            makeCase("<=", params: ["2.0", "1.0"], result: false),
            makeCase("<=", params: ["3", "2", "1"], result: false),
            makeCase("<=", params: ["3.0", "2.0", "1.0"], result: false),
            makeCase("<=", params: ["3.0", "2", "1.0"], result: false),

            makeCase("<=", params: ["1", "2", "1"], result: false),
            makeCase("<=", params: ["1.0", "2.0", "1.0"], result: false),
            makeCase("<=", params: ["1.0", "2", "1.0"], result: false),

            makeCase("<=", params: ["3", "2", "3"], result: false),
            makeCase("<=", params: ["3.0", "2.0", "3.0"], result: false),
            makeCase("<=", params: ["3.0", "2", "3.0"], result: false),

            makeCase(">", params: ["2", "1"], result: true),
            makeCase(">", params: ["2.0", "1"], result: true),
            makeCase(">", params: ["2", "1.0"], result: true),
            makeCase(">", params: ["2.0", "1.0"], result: true),
            makeCase(">", params: ["3", "2", "1"], result: true),
            makeCase(">", params: ["3.0", "2.0", "1.0"], result: true),
            makeCase(">", params: ["3.0", "2", "1.0"], result: true),

            makeCase(">", params: ["1", "2"], result: false),
            makeCase(">", params: ["1.0", "2"], result: false),
            makeCase(">", params: ["1", "2.0"], result: false),
            makeCase(">", params: ["1.0", "2.0"], result: false),
            makeCase(">", params: ["1", "2", "3"], result: false),
            makeCase(">", params: ["1.0", "2.0", "3.0"], result: false),
            makeCase(">", params: ["1.0", "2", "3.0"], result: false),

            makeCase(">", params: ["1", "2", "1"], result: false),
            makeCase(">", params: ["1.0", "2.0", "1.0"], result: false),
            makeCase(">", params: ["1.0", "2", "1.0"], result: false),

            makeCase(">", params: ["3", "2", "3"], result: false),
            makeCase(">", params: ["3.0", "2.0", "3.0"], result: false),
            makeCase(">", params: ["3.0", "2", "3.0"], result: false),

            makeCase(">=", params: ["2", "1"], result: true),
            makeCase(">=", params: ["2.0", "1"], result: true),
            makeCase(">=", params: ["2", "1.0"], result: true),
            makeCase(">=", params: ["2.0", "1.0"], result: true),
            makeCase(">=", params: ["3", "2", "1"], result: true),
            makeCase(">=", params: ["3.0", "2.0", "1.0"], result: true),
            makeCase(">=", params: ["3.0", "2", "1.0"], result: true),

            makeCase(">=", params: ["1", "1"], result: true),
            makeCase(">=", params: ["1.0", "1"], result: true),
            makeCase(">=", params: ["1", "1.0"], result: true),
            makeCase(">=", params: ["1.0", "1.0"], result: true),
            makeCase(">=", params: ["1", "1", "1"], result: true),
            makeCase(">=", params: ["1.0", "1.0", "1.0"], result: true),
            makeCase(">=", params: ["1.0", "1", "1.0"], result: true),

            makeCase(">=", params: ["1", "2"], result: false),
            makeCase(">=", params: ["1.0", "2"], result: false),
            makeCase(">=", params: ["1", "2.0"], result: false),
            makeCase(">=", params: ["1.0", "2.0"], result: false),
            makeCase(">=", params: ["1", "2", "3"], result: false),
            makeCase(">=", params: ["1.0", "2.0", "3.0"], result: false),
            makeCase(">=", params: ["1.0", "2", "3.0"], result: false),

            makeCase(">=", params: ["1", "2", "1"], result: false),
            makeCase(">=", params: ["1.0", "2.0", "1.0"], result: false),
            makeCase(">=", params: ["1.0", "2", "1.0"], result: false),

            makeCase(">=", params: ["3", "2", "3"], result: false),
            makeCase(">=", params: ["3.0", "2.0", "3.0"], result: false),
            makeCase(">=", params: ["3.0", "2", "3.0"], result: false),
        ]

        for c in cases {
            let expr = Expression.call(.init(target: .symbol(Symbol(c.symbol)), params: c.params.map { Expression.value(.number($0)) }))
            let result = try evaluateToOutput(expression: expr, in: .withBuiltins)
            XCTAssertEqual(try XCTUnwrap(result.boolean), c.result, file: c.file, line: c.line)
        }
    }
}
