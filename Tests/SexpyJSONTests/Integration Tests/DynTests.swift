import SexpyJSON
import XCTest

final class DynTests: XCTestCase {
    func test() throws {
        let definitions: [String] = [
            "(define cd23 (dynfn [] Orientation))",
        ]

        let input = #"""
        { "cd23": (cd23) }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        evaluator.set(value: { value in value[0].boolean }, for: "test")
        for definition in definitions {
            let parsedDefinition = try parser.parse(source: definition)
            try evaluator.evaluate(expression: parsedDefinition)
        }
        evaluator.set(value: "Landscape", for: "Orientation")
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject(includeNilObjectFields: true) as? [String: String])
        _ = try JSONSerialization.data(withJSONObject: obj, options: [.fragmentsAllowed])

        XCTAssertEqual(obj, ["cd23": "Landscape"])
    }
}
