@testable import SexpyJSON
import XCTest

final class EvaluatorValueTests: XCTestCase {
    func testString() throws {
        let expr = Expression.value(.string("foo"))
        let outputValue = try evaluateToOutput(expression: expr, in: Context(namespace: .empty))
        XCTAssertEqual(outputValue, .string("foo"))
    }

    func testNumber() throws {
        let expr = Expression.value(.number("1.2"))
        let outputValue = try evaluateToOutput(expression: expr, in: Context(namespace: .empty))
        XCTAssertEqual(try XCTUnwrap(outputValue.number), 1.2, accuracy: 0.0001)
    }

    func testArray() throws {
        let expr = Expression.value(.array([.value(.string("a")), .value(.string("b"))]))
        let outputValue = try evaluateToOutput(expression: expr, in: Context(namespace: .empty))
        XCTAssertEqual(outputValue, .array([.string("a"), .string("b")]))
    }

    func testObject() throws {
        let expr = Expression.value(.object([
            .init(name: "field1", value: .value(.string("asdf"))),
            .init(name: "field2", value: .value(.number("-9.2"))),
        ]))
        let outputValue = try evaluateToOutput(expression: expr, in: Context(namespace: .empty))
        guard case let .object(ob) = outputValue else {
            XCTFail("Not an object: \(outputValue)")
            return
        }
        XCTAssertEqual(ob.count, 2)
        XCTAssertEqual(ob[0], .init(name: "field1", value: .string("asdf")))
        XCTAssertEqual(ob[1].name, "field2")
        XCTAssertEqual(try XCTUnwrap(ob[1].value.number), -9.2, accuracy: 0.00001)
    }
}
