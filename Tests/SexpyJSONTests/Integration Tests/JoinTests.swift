import SexpyJSON
import XCTest

final class JoinTests: XCTestCase {
    func test() throws {
        let input = #"""
        {
            "a": (join-string "" []),
            "b": (join-string "" ["q"]),
            "c": (join-string "" ["q", "", "w", "e"]),
            "d": (join-string "," []),
            "e": (join-string "," ["q"]),
            "f": (join-string "," ["q", "w", "", "e"])
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(obj["a"] as? String, "")
        XCTAssertEqual(obj["b"] as? String, "q")
        XCTAssertEqual(obj["c"] as? String, "qwe")
        XCTAssertEqual(obj["d"] as? String, "")
        XCTAssertEqual(obj["e"] as? String, "q")
        XCTAssertEqual(obj["f"] as? String, "q,w,,e")
    }
}
