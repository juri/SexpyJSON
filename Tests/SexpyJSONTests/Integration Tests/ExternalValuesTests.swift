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
}
