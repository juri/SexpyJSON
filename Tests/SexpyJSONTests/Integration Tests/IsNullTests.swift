import SexpyJSON
import XCTest

final class IsNullTests: XCTestCase {
    func test() throws {
        let input = #"""
        {
            "a": (is-null null),
            "b": (is-null externalNull),
            "c": (is-null 10),
            "d": (is-null true),
            "e": (is-null false),
            "f": (is-null "hello"),
            "g": (is-null []),
            "h": (is-null {}),
            "i": (map is-null [null, 20, null])
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.setNull(for: "externalNull")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
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
