import Foundation
import SexpyJSON
import XCTest

final class FnSyntaxTests: XCTestCase {
    func testAsParameter() throws {
        let input = #"""
        {
            "a": (map (fn [a] (* a 2)) [1, 2, 3])
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let ob = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: ob, options: [.fragmentsAllowed])
        let val = try XCTUnwrap(ob["a"] as? [Double])
        assertEqual(val, [2.0, 4.0, 6.0], accuracy: 0.00001)
    }

    func testAsCallTarget() throws {
        let input = #"""
        ((fn [a] (* a 2)) 14)
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let ob = try XCTUnwrap(output.outputToJSONObject() as? Double)
        _ = try JSONSerialization.data(withJSONObject: ob, options: [.fragmentsAllowed])
        XCTAssertEqual(ob, 28.0, accuracy: 0.00001)
    }
}
