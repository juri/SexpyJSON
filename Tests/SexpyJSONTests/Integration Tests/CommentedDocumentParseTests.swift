import SexpyJSON
import XCTest

final class CommentedDocumentParseTests: XCTestCase {
    func testInitialComment() throws {
        let input = #"""
        # plop
        {}
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        XCTAssertTrue(obj.isEmpty)
    }

    func testTrailingComment() throws {
        let input = #"""
        {}
        # plop
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        XCTAssertTrue(obj.isEmpty)
    }

    func testMiddleWholeLineComment() throws {
        let input = #"""
        {
            "a": "b",
            # plop
            "c": "d"
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: String])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        XCTAssertEqual(obj, ["a": "b", "c": "d"])
    }

    func testMiddleLineEndComment() throws {
        let input = #"""
        {
            "a": "b", # plop
            "c": "d"
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: String])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        XCTAssertEqual(obj, ["a": "b", "c": "d"])
    }

    func testMultilineComment() throws {
        let input = #"""
        {
            "a": "b", # plop
            # zap
            # more
            "c": "d"
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: String])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        XCTAssertEqual(obj, ["a": "b", "c": "d"])
    }

    func testNoSpaceBeforeComment() throws {
        let input = #"""
        {
            "a": "b",# plop
            "c": "d"#quux
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: String])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])
        XCTAssertEqual(obj, ["a": "b", "c": "d"])
    }
}
