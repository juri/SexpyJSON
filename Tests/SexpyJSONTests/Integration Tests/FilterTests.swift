@testable import SexpyJSON
import XCTest

final class FilterTests: XCTestCase {
    func testFilterOverDefinedArray() throws {
        let definition = #"""
        (define values [1, 2, 3, 4, 5])
        """#

        let input = #"""
        {
            "k1": (filter (fn [val] (> val 3)) values)
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
        XCTAssertEqual(value.count, 2)
        XCTAssertEqual(value[0], 4.0, accuracy: 0.00001)
        XCTAssertEqual(value[1], 5.0, accuracy: 0.00001)
    }

    func testFilterWithNot() throws {
        let definition = #"""
        (define values ["aaa", "bb", "cccc"])
        """#

        let input = #"""
        {
            "k1": (filter (fn [val] (not (> (len val) 2))) values)
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let value = try XCTUnwrap(obj["k1"] as? [String])
        XCTAssertEqual(value.count, 1)
        XCTAssertEqual(value[0], "bb")
    }
}
