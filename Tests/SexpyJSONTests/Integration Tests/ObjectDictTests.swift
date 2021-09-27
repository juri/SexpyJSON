import SexpyJSON
import XCTest

final class ObjectDictTests: XCTestCase {
    func test() throws {
        let input = #"""
        {
            "k1": (object),
            "k2": (dict),
            "k3": (object (concat "k" "e" "y") 1.0),
            "k4": (dict (concat "K" "E" "Y") 2.0)
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        let v1 = try XCTUnwrap(obj["k1"] as? [String: Any])
        let v2 = try XCTUnwrap(obj["k2"] as? [String: Any])
        let v3 = try XCTUnwrap(obj["k3"] as? [String: Any])
        let v4 = try XCTUnwrap(obj["k4"] as? [String: Any])
        XCTAssertEqual(v1.count, 0)
        XCTAssertEqual(v2.count, 0)
        XCTAssertEqual(v3.count, 1)
        XCTAssertEqual(v4.count, 1)

        XCTAssertEqual(try XCTUnwrap(v3["key"] as? Double), 1.0, accuracy: 0.00001)
        XCTAssertEqual(try XCTUnwrap(v4["KEY"] as? Double), 2.0, accuracy: 0.00001)
    }
}
