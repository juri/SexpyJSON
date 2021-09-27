import SexpyJSON
import XCTest

final class ApplyTests: XCTestCase {
    func test() throws {
        let definition = #"""
        (define myfun (fn (a b c) (* a b c)))
        """#

        let input = #"""
        {
            "k1": (apply myfun [3, 4, 5])
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let value = try XCTUnwrap(obj["k1"] as? Double)
        XCTAssertEqual(value, 60.0, accuracy: 0.00001)
    }
}
