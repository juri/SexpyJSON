import SexpyJSON
import XCTest

final class ExprInJSONTests: XCTestCase {
    func testAddInJSON() throws {
        let input = #"  {"zap": "bang", "calculated": (+ 4 5)}"#
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(obj["zap"] as? String, "bang")
        XCTAssertEqual(try XCTUnwrap(obj["calculated"] as? Double), 9.0, accuracy: 0.0001)
    }

    func testFnInLetCantSeeItsOwnName() throws {
        let input = #"""
        {
            "zap": "bang",
            "calculated": (let (testf (fn [a]
                                        (if (eq a "ccc")
                                            a
                                            (testf (concat a "c")))))
                                (testf "c"))
        }
        """#

        let expr = try SXPJParser().parse(source: input)
        XCTAssertThrowsError(try expr.evaluate()) { error in
            guard let error = error as? SXPJError, case let .evaluationFailure(msg) = error else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            XCTAssertEqual(msg, #"Missing value: Symbol(name: "testf")"#)
        }
    }

    func testOuterSexp() throws {
        let input = #"(* 5 6)"#
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? Double)
        XCTAssertEqual(obj, 30.0, accuracy: 0.00001)
    }

    func testDefine() throws {
        let definition = #"""
        (define testf (fn [a]
                        (if (eq a "ccc")
                            a
                            (testf (concat a "c")))))
        """#

        let input = #"""
        {
            "zap": "bang",
            "calculated": (testf "c")
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(obj["zap"] as? String, "bang")
        XCTAssertEqual(try XCTUnwrap(obj["calculated"] as? String), "ccc")
    }

    func testConcatArrays() throws {
        let input = #"""
        {
            "zap": (concat [1, 2] [3, 4])
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let zap = try XCTUnwrap(obj["zap"] as? [Double])
        assertEqual(zap, [1.0, 2.0, 3.0, 4.0], accuracy: 0.0001)
    }
}
