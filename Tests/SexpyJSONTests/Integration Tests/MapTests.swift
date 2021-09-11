@testable import SexpyJSON
import XCTest

final class MapTests: XCTestCase {
    func testMapOverDefinedArray() throws {
        let definition = #"""
        (define values [1, 2, 3, 4, 5])
        """#

        let input = #"""
        {
            "k1": (map (fn [val] (+ 1 val)) values)
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
        XCTAssertEqual(value.count, 5)
        XCTAssertEqual(value[0], 2.0, accuracy: 0.00001)
        XCTAssertEqual(value[1], 3.0, accuracy: 0.00001)
        XCTAssertEqual(value[2], 4.0, accuracy: 0.00001)
        XCTAssertEqual(value[3], 5.0, accuracy: 0.00001)
        XCTAssertEqual(value[4], 6.0, accuracy: 0.00001)
    }

    func testMapWithSpecialOperatorOverDefinedArray() throws {
        let definition = #"""
        (define values [1, 2, 3, 4, 5])
        """#

        let input = #"""
        {
            "k1": (map (fn [val] (if (> val 3) (+ val 1) (- val 1))) values)
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
        XCTAssertEqual(value.count, 5)
        XCTAssertEqual(value[0], 0.0, accuracy: 0.00001)
        XCTAssertEqual(value[1], 1.0, accuracy: 0.00001)
        XCTAssertEqual(value[2], 2.0, accuracy: 0.00001)
        XCTAssertEqual(value[3], 5.0, accuracy: 0.00001)
        XCTAssertEqual(value[4], 6.0, accuracy: 0.00001)
    }
}
