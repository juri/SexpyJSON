import SexpyJSON
import XCTest

final class CondTests: XCTestCase {
    func test() throws {
        let input = #"""
        {
            "no-args": (cond),

            "one-false-branch": (cond false "hello"),
            "one-true-branch": (cond true "hello"),
            "two-branches-first-match": (cond true "hello" false "world"),
            "two-branches-second-match": (cond false "hello" true "world"),
            "two-branches-none-match": (cond false "hello" false "world"),

            "call-one-false-branch": (cond (test false) "hello"),
            "call-one-true-branch": (cond (test true) "hello"),
            "call-two-branches-first-match": (cond (test true) "hello" (test false) "world"),
            "call-two-branches-second-match": (cond (test false) "hello" (test true) "world"),
            "call-two-branches-none-match": (cond (test false) "hello" (test false) "world")
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: { value in value[0].boolean }, for: "test")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject(includeNilObjectFields: true) as? [String: String?])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(
            obj,
            [
                "no-args": nil,

                "one-false-branch": nil,
                "one-true-branch": "hello",
                "two-branches-first-match": "hello",
                "two-branches-second-match": "world",
                "two-branches-none-match": nil,

                "call-one-false-branch": nil,
                "call-one-true-branch": "hello",
                "call-two-branches-first-match": "hello",
                "call-two-branches-second-match": "world",
                "call-two-branches-none-match": nil,
            ]
        )
    }
}
