import SexpyJSON
import XCTest

final class NameTests: XCTestCase {
    func testName() throws {
        let define = #"""
        (define bound-name "hello")
        """#

        let input = #"""
        {
            "a": (name "bound-name")
        }
        """#

        let parser = SXPJParser()
        let defineExpr = try parser.parse(source: define)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: defineExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(obj["a"] as? String, "hello")
    }

    func testHasName() throws {
        let define = #"""
        (define bound-name "hello")
        """#

        let input = #"""
        {
            "a": (has-name "bound-name"),
            "b": (has-name "unbound-name")
        }
        """#

        let parser = SXPJParser()
        let defineExpr = try parser.parse(source: define)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: defineExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(obj["a"] as? Bool, true)
        XCTAssertEqual(obj["b"] as? Bool, false)
    }

    func testNameOpt() throws {
        let define = #"""
        (define bound-name "hello")
        """#

        let input = #"""
        {
            "a": (name? "bound-name"),
            "b": (name? "unbound-name")
        }
        """#

        let parser = SXPJParser()
        let defineExpr = try parser.parse(source: define)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: defineExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject(includeNilObjectFields: true) as? [String: String?])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(
            obj,
            [
                "a": "hello",
                "b": nil,
            ]
        )
    }
}
