import SexpyJSON
import XCTest

final class ConvertObjectTests: XCTestCase {
    func test() throws {
        let definition = #"""
            (define defined-ob {"k1": "maple", "k2": "brick"})
        """#

        let input = #"""
        {
            "k1": (as-dict defined-ob),
            "k2": (as-object (as-dict defined-ob)),
            "k3": (as-object injected-dict),
            "k4": (as-dict (as-object injected-dict))
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: ["k1": "fact", "k2": "pasta"], for: "injected-dict")
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [])

        let v1 = try XCTUnwrap(obj["k1"] as? [String: String])
        let v2 = try XCTUnwrap(obj["k2"] as? [String: String])
        let v3 = try XCTUnwrap(obj["k3"] as? [String: String])
        let v4 = try XCTUnwrap(obj["k4"] as? [String: String])

        XCTAssertEqual(v1, ["k1": "maple", "k2": "brick"])
        XCTAssertEqual(v2, ["k1": "maple", "k2": "brick"])
        XCTAssertEqual(v3, ["k1": "fact", "k2": "pasta"])
        XCTAssertEqual(v4, ["k1": "fact", "k2": "pasta"])
    }
}
