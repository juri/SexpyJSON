@testable import SexpyJSON
import XCTest

final class ParsedToExpressionTests: XCTestCase {
    func testConversion() throws {
        let (element, remainder) = buildParser().run(#"(target1 {"key1": (target2)})"#)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        XCTAssertEqual(
            expr,
            .call(.init(target: .symbol(Symbol("target1")), params: [
                .value(.object([
                    .init(name: "key1", value: .call(.init(target: .symbol(Symbol("target2")), params: []))),
                ])),
            ]))
        )
    }
}
