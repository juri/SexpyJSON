@testable import SexpyJSON
import XCTest

final class SimpleJSONTests: XCTestCase {
    func testString() throws {
        let input = "\"hello\""
        let (element, remainder) = buildParser().run(input)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        let output = try evaluateToOutput(expression: expr, in: .withBuiltins)
        let obj = outputToJSONObject(output)
        XCTAssertEqual(obj as? String, "hello")
    }

    func testNumber() throws {
        let input = "-5.6"
        let (element, remainder) = buildParser().run(input)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        let output = try evaluateToOutput(expression: expr, in: .withBuiltins)
        let obj = outputToJSONObject(output)
        XCTAssertEqual(try XCTUnwrap(obj as? Double), -5.6, accuracy: 0.00001)
    }

    func testArray() throws {
        let input = #"["zap", "bang"]"#
        let (element, remainder) = buildParser().run(input)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        let output = try evaluateToOutput(expression: expr, in: .withBuiltins)
        let obj = outputToJSONObject(output)
        XCTAssertEqual(try XCTUnwrap(obj as? [String]), ["zap", "bang"])
    }

    func testObject() throws {
        let input = #"{"zap": "bang", "arr": ["rrr", "rr"]}"#
        let (element, remainder) = buildParser().run(input)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        let output = try evaluateToOutput(expression: expr, in: .withBuiltins)
        let obj = try XCTUnwrap(outputToJSONObject(output) as? [String: Any])
        XCTAssertEqual(obj["zap"] as? String, "bang")
        XCTAssertEqual(obj["arr"] as? [String], ["rrr", "rr"])
    }

    func testNull() throws {
        let input = "null"
        let (element, remainder) = buildParser().run(input)
        XCTAssertEqual(remainder, ""[...])
        let reallyElement = try XCTUnwrap(element)
        let expr = Expression(element: reallyElement)
        let output = try evaluateToOutput(expression: expr, in: .withBuiltins)
        let obj = outputToJSONObject(output)
        XCTAssertNil(obj)
    }
}
