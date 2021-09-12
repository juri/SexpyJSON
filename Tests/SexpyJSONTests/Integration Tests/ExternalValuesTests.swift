@testable import SexpyJSON
import XCTest

final class ExternalValuesTests: XCTestCase {
    func testInteger() throws {
        let input = #"""
        {
            "a": a,
            "b": (+ 1 b)
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: 3, for: "a")
        evaluator.set(value: 6, for: "b")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(try XCTUnwrap(obj["a"] as? Double), 3.0, accuracy: 0.0001)
        XCTAssertEqual(try XCTUnwrap(obj["b"] as? Double), 7.0, accuracy: 0.0001)
    }

    func testString() throws {
        let input = #"""
        {
            "a": a,
            "b": (* 2 (len b))
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: "blap", for: "a")
        evaluator.set(value: "zap", for: "b")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(try XCTUnwrap(obj["a"] as? String), "blap")
        XCTAssertEqual(try XCTUnwrap(obj["b"] as? Double), 6.0, accuracy: 0.0001)
    }

    func testDouble() throws {
        let input = #"""
        {
            "a": a,
            "b": (> 3.0 b)
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: 5.0, for: "a")
        evaluator.set(value: 1.0, for: "b")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(try XCTUnwrap(obj["a"] as? Double), 5.0, accuracy: 0.0001)
        XCTAssertTrue(try XCTUnwrap(obj["b"] as? Bool))
    }

    func testBoolean() throws {
        let input = #"""
        {
            "a": a,
            "b": b
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: true, for: "a")
        evaluator.set(value: false, for: "b")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertTrue(try XCTUnwrap(obj["a"] as? Bool))
        XCTAssertFalse(try XCTUnwrap(obj["b"] as? Bool))
    }

    func testNull() throws {
        let input = #"""
        {
            "a": a
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.setNull(for: "a")
        let output = try evaluator.evaluate(expression: inputExpr)
        let objMembers = try XCTUnwrap(output.object)
        XCTAssertEqual(objMembers.count, 1)
        XCTAssertEqual(objMembers[0].name, "a")
        XCTAssertEqual(objMembers[0].value, .null)
    }

    func testArray() throws {
        let input = #"""
        {
            "concatted": (concat arr1 arr2 arr3),
            "lenghts": [(len arr1), (len arr2), (len arr3)],
            "mapped1": (map (fn [elem] (* 3 elem)) arr1),
            "mapped2": (map (fn [elem] (* 4 elem)) arr2),
            "mapped3": (map (fn [elem] (* 5 elem)) arr3),
            "filtered1": (filter (fn [elem] (< elem 2)) arr1),
            "filtered2": (filter (fn [elem] (< elem 20)) arr2),
            "filtered3": (filter (fn [elem] (< elem 200)) arr3)
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(array: [1, 2, 3], for: "arr1")
        evaluator.set(array: [10, 20, 30], for: "arr2")
        try evaluator.setPreconvert(array: [100, 200, 300], for: "arr3")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])

        let concatted = try XCTUnwrap(obj["concatted"] as? [Double])
        let lengths = try XCTUnwrap(obj["lenghts"] as? [Double])
        let mapped1 = try XCTUnwrap(obj["mapped1"] as? [Double])
        let mapped2 = try XCTUnwrap(obj["mapped2"] as? [Double])
        let mapped3 = try XCTUnwrap(obj["mapped3"] as? [Double])
        let filtered1 = try XCTUnwrap(obj["filtered1"] as? [Double])
        let filtered2 = try XCTUnwrap(obj["filtered2"] as? [Double])
        let filtered3 = try XCTUnwrap(obj["filtered3"] as? [Double])

        assertEqual(concatted, [1.0, 2.0, 3.0, 10.0, 20.0, 30.0, 100.0, 200.0, 300.0], accuracy: 0.0001)
        assertEqual(lengths, [3.0, 3.0, 3.0], accuracy: 0.0001)
        assertEqual(mapped1, [3.0, 6.0, 9.0], accuracy: 0.0001)
        assertEqual(mapped2, [40.0, 80.0, 120.0], accuracy: 0.0001)
        assertEqual(mapped3, [500.0, 1000.0, 1500.0], accuracy: 0.0001)
        assertEqual(filtered1, [1.0], accuracy: 0.0001)
        assertEqual(filtered2, [10.0], accuracy: 0.0001)
        assertEqual(filtered3, [100.0], accuracy: 0.0001)
    }
}
