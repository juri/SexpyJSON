@testable import SexpyJSON
import XCTest

final class EvaluatorMathTests: XCTestCase {
    // MARK: Add

    func testAddOneNumber() throws {
        let expr = Expression.call(.init(target: .symbol(.addition), params: [.value(.number("-68"))]))
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -68.0, accuracy: 0.0001)
    }

    func testAddTwoNumbers() throws {
        let expr = Expression.call(
            .init(target: .symbol(.addition), params: [.value(.number("1")), .value(.number("2"))])
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 3.0, accuracy: 0.0001)
    }

    func testAddThreeNumbers() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(.addition),
                params: [.value(.number("1")), .value(.number("2")), .value(.number("-4"))]
            )
        )
        let outputValue = try evaluateToOutput(expression: expr, in: .withBuiltins)
        XCTAssertEqual(try XCTUnwrap(outputValue.number), -1.0, accuracy: 0.0001)
    }

    func testAddAdd() throws {
        let expr = Expression.call(
            .init(
                target: .symbol(.addition),
                params: [
                    .value(.number("1")),
                    .call(.init(target: .symbol(.addition), params: [
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
}
