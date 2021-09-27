import SexpyJSON
import XCTest

final class NativeFunctionTests: XCTestCase {
    func testVoidReturning() throws {
        let input = #"""
        {
            "key1": (let () (log "hello!") "value1"),
            "key2": (let () (log "hello" "again!") "value2")
        }
        """#

        var receivedValues = [String]()

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        func storeStrings(_ params: [SXPJOutputValue]) throws {
            let strings = params.compactMap(\.string)
            receivedValues.append(contentsOf: strings)
        }
        evaluator.set(value: storeStrings(_:), for: "log")

        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let value1 = try XCTUnwrap(obj["key1"] as? String)
        let value2 = try XCTUnwrap(obj["key2"] as? String)
        XCTAssertEqual(value1, "value1")
        XCTAssertEqual(value2, "value2")
        XCTAssertEqual(receivedValues, ["hello!", "hello", "again!"])
    }

    func testValueReturning() throws {
        let input = #"""
        {
            "key1": (let () (tf "hello!") "value1")
        }
        """#

        let parser = SXPJParser()
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        func tf(_ params: [SXPJOutputValue]) throws -> Any? {
            let strings = params.compactMap(\.string)
            return strings.map { String($0.reversed()) }
        }
        evaluator.set(value: tf(_:), for: "tf")

        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
        let value1 = try XCTUnwrap(obj["key1"] as? String)
        XCTAssertEqual(value1, "value1")
    }
}
