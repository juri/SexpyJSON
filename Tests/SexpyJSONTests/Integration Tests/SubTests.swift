@testable import SexpyJSON
import XCTest

final class SubTests: XCTestCase {
    func testSuccessfulAccess() throws {
        let input = #"""
        (let (arr ["a", "b", "c", "d"]
              obj {"foo": "bar", "zap": "bang"})
            {
                "fromArr": (sub arr 2),
                "fromObj": (sub obj "zap"),
                "fromNativeArr": (sub nArr 3)
            }
        )
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: [101, 102, 103, 104, 105, 106], for: "nArr")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])

        let fromArr = try XCTUnwrap(obj["fromArr"] as? String)
        let fromObj = try XCTUnwrap(obj["fromObj"] as? String)
        let fromNativeArr = try XCTUnwrap(obj["fromNativeArr"] as? Double)

        XCTAssertEqual(fromArr, "c")
        XCTAssertEqual(fromObj, "bang")
        XCTAssertEqual(fromNativeArr, 104.0, accuracy: 0.0001)
    }

    func testLowerBoundsCheckOnArray() throws {
        let input = #"""
        (let (arr ["a", "b", "c", "d"]
              obj {"foo": "bar", "zap": "bang"})
            {
                "fromArr": (sub arr -1)
            }
        )
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        XCTAssertThrowsError(try evaluator.evaluate(expression: inputExpr))
    }

    func testUpperBoundsCheckOnArray() throws {
        let input = #"""
        (let (arr ["a", "b", "c", "d"]
              obj {"foo": "bar", "zap": "bang"})
            {
                "fromArr": (sub arr 10)
            }
        )
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        XCTAssertThrowsError(try evaluator.evaluate(expression: inputExpr))
    }

    func testLowerBoundsCheckOnNativeArray() throws {
        let input = #"""
        (let (arr ["a", "b", "c", "d"]
              obj {"foo": "bar", "zap": "bang"})
            {
                "fromNativeArr": (sub nArr -100)
            }
        )
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        XCTAssertThrowsError(try evaluator.evaluate(expression: inputExpr))
    }

    func testUpperBoundsCheckOnNativeArray() throws {
        let input = #"""
        (let (arr ["a", "b", "c", "d"]
              obj {"foo": "bar", "zap": "bang"})
            {
                "fromNativeArr": (sub nArr 100)
            }
        )
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        XCTAssertThrowsError(try evaluator.evaluate(expression: inputExpr))
    }

    func testNullFromObject() throws {
        let input = #"""
        (let (arr ["a", "b", "c", "d"]
              obj {"foo": "bar", "zap": "bang"})
            {
                "fromObjFound": (not (is-nil (sub obj "foo"))),
                "fromObjNotFound": (not (is-nil (sub obj "notThere")))
            }
        )
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])

        let fromObjFound = try XCTUnwrap(obj["fromObjFound"] as? Bool)
        let fromObjNotFound = try XCTUnwrap(obj["fromObjNotFound"] as? Bool)

        XCTAssertTrue(fromObjFound)
        XCTAssertFalse(fromObjNotFound)
    }
}