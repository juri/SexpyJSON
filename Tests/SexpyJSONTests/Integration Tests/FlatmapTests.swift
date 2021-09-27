import SexpyJSON
import XCTest

final class FlatmapTests: XCTestCase {
    func testFlatmapOverDefinedArray() throws {
        let definition = #"""
        (define values [1, 2, 3, 4, 5])
        """#

        let input = #"""
        {
            "k1": (flatmap (fn [val] [(* 10 val), (* 100 val)]) values)
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let value = try XCTUnwrap(obj["k1"] as? [Double])
        assertEqual(value, [10.0, 100.0, 20.0, 200.0, 30.0, 300.0, 40.0, 400.0, 50.0, 500.0], accuracy: 0.0001)
    }

    func testFlatmapWithSpecialOperatorOverDefinedArray() throws {
        let definition = #"""
        (define values [1, 2, 3, 4, 5])
        """#

        let input = #"""
        {
            "k1": (flatmap (fn [val] (if (> val 3) [val, (+ val 1)] [(- val 1), val])) values)
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let value = try XCTUnwrap(obj["k1"] as? [Double])
        assertEqual(value, [0.0, 1.0, 1.0, 2.0, 2.0, 3.0, 4.0, 5.0, 5.0, 6.0], accuracy: 0.0001)
    }
}
