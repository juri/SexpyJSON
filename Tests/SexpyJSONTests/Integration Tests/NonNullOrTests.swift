import SexpyJSON
import XCTest

final class NonNullOrTests: XCTestCase {
    func test() throws {
        let input = #"""
        {
            "no-args": (??),
            "one-arg-null": (?? null),
            "one-arg-not-null": (?? "hello"),
            "one-arg-call-null": (?? (test "null")),
            "one-arg-call-not-null": (?? (test "asdf")),

            "two-args-first-null": (?? null "hello"),
            "two-args-second-null": (?? "hello" null),
            "two-args-both-null": (?? null null),
            "two-args-neither-null": (?? "hello" "world"),
            "two-args-first-call-null": (?? (test "null") "world"),
            "two-args-first-call-non-null": (?? (test "qewr") "world"),

            "three-args-first-null": (?? null "world" "again"),
            "three-args-second-null": (?? "hello" null "again"),
            "three-args-third-null": (?? "hello" "world" null),
            "three-args-first-two-null": (?? null null "again"),
            "three-args-second-two-null": (?? "hello" null null),
            "three-args-first-and-third-null": (?? null "world" null),
            "three-args-all-null": (?? null null null),
            "three-args-none-null": (?? "hello" "world" "again")
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: { value in value[0].string == "null" ? nil : "not null" }, for: "test")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject(includeNilObjectFields: true) as? [String: String?])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(
            obj,
            [
                "no-args": nil,
                "one-arg-null": nil,
                "one-arg-not-null": "hello",
                "one-arg-call-null": nil,
                "one-arg-call-not-null": "not null",

                "two-args-first-null": "hello",
                "two-args-second-null": "hello",
                "two-args-both-null": nil,
                "two-args-neither-null": "hello",
                "two-args-first-call-null": "world",
                "two-args-first-call-non-null": "not null",

                "three-args-first-null": "world",
                "three-args-second-null": "hello",
                "three-args-third-null": "hello",
                "three-args-first-two-null": "again",
                "three-args-second-two-null": "hello",
                "three-args-first-and-third-null": "world",
                "three-args-all-null": nil,
                "three-args-none-null": "hello",
            ]
        )
    }
}
