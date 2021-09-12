@testable import SexpyJSON
import XCTest

final class IsNilTests: XCTestCase {
    func test() throws {
        let input = #"""
        {
            "a": (is-nil null),
            "b": (is-nil externalNull),
            "c": (is-nil 10),
            "d": (is-nil true),
            "e": (is-nil false),
            "f": (is-nil "hello"),
            "g": (is-nil []),
            "h": (is-nil {}),
            "i": (map is-nil [null, 20, null])
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.setNull(for: "externalNull")
        let output = try evaluator.evaluate(expression: inputExpr)
        let members = try XCTUnwrap(output.object)

        XCTAssertEqual(
            members,
            [
                .init(name: "a", value: .boolean(true)),
                .init(name: "b", value: .boolean(true)),
                .init(name: "c", value: .boolean(false)),
                .init(name: "d", value: .boolean(false)),
                .init(name: "e", value: .boolean(false)),
                .init(name: "f", value: .boolean(false)),
                .init(name: "g", value: .boolean(false)),
                .init(name: "h", value: .boolean(false)),
                .init(name: "i", value: .array([.boolean(true), .boolean(false), .boolean(true)])),
            ]
        )
    }
}
