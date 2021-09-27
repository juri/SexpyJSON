import SexpyJSON
import XCTest

final class SimpleJSONTests: XCTestCase {
    func testString() throws {
        let input = "\"hello\""
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? String)
        XCTAssertEqual(obj, "hello")
    }

    func testNumber() throws {
        let input = "-5.6"
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? Double)
        XCTAssertEqual(obj, -5.6, accuracy: 0.00001)
    }

    func testArray() throws {
        let input = #"["zap", "bang"]"#
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String])
        XCTAssertEqual(obj, ["zap", "bang"])
    }

    func testObject() throws {
        let input = #"{"zap": "bang", "arr": ["rrr", "rr"]}"#
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        XCTAssertEqual(obj["zap"] as? String, "bang")
        XCTAssertEqual(obj["arr"] as? [String], ["rrr", "rr"])
    }

    func testNull() throws {
        let input = "null"
        let expr = try SXPJParser().parse(source: input)
        let output = try expr.evaluate()
        let obj = output.outputToJSONObject()
        XCTAssertNil(obj)
    }
}
