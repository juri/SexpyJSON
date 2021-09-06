@testable import SexpyJSON
import XCTest

final class ExprInJSONTests: XCTestCase {
    func testAddInJSON() throws {
        let input = #"{"zap": "bang", "calculated": (+ 4 5)}"#
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(obj["zap"] as? String, "bang")
        XCTAssertEqual(try XCTUnwrap(obj["calculated"] as? Double), 9.0, accuracy: 0.0001)
    }
}
