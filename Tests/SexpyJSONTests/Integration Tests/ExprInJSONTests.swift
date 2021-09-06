@testable import SexpyJSON
import XCTest

final class ExprInJSONTests: XCTestCase {
    func testAddInJSON() throws {
        let input = #"{"zap": "bang", "calculated": (+ 4 5)}"#
        let (element, remainder) = buildParser().run(input)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        let output = try evaluateToOutput(expression: expr, in: .withBuiltins)
        let obj = try XCTUnwrap(outputToJSONObject(output) as? [String: Any])
        XCTAssertEqual(obj["zap"] as? String, "bang")
        XCTAssertEqual(try XCTUnwrap(obj["calculated"] as? Double), 9.0, accuracy: 0.0001)
    }
}
