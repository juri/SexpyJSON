import XCTest
@testable import SexpyJSON

final class ArraySyntaxTests: XCTestCase {
    func testEmpty() throws {
        let (element, remainder) = buildParser().run("[]")
        XCTAssertEqual(element, SexpyJSONElement.array([]))
        XCTAssertEqual(remainder, ""[...])
    }

    func testOneElement() throws {
        let (element, remainder) = buildParser().run("[1]")
        XCTAssertEqual(element, SexpyJSONElement.array([.number("1")]))
        XCTAssertEqual(remainder, ""[...])
    }

    func testOneSymbolElement() throws {
        let (element, remainder) = buildParser().run("[blep]")
        XCTAssertEqual(try XCTUnwrap(element), SexpyJSONElement.array([SexpyJSONElement.symbol(.init("blep"))]))
        XCTAssertEqual(remainder, ""[...])
    }

    func testStringsNumbers() throws {
        let (element, remainder) = buildParser().run(#"[1, "first", 42, "second"]"#)
        let actualElement = try XCTUnwrap(element)
        XCTAssertEqual(actualElement, SexpyJSONElement.array([
            .number("1"),
            .string("first"),
            .number("42"),
            .string("second")
        ]))
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testNested() throws {
        let (element, remainder) = buildParser().run(#"[1, "first", 42, "second", [11, [], 6, ["deep"]]]"#)
        let actualElement = try XCTUnwrap(element)
        XCTAssertEqual(actualElement, SexpyJSONElement.array([
            .number("1"),
            .string("first"),
            .number("42"),
            .string("second"),
            .array([
                .number("11"),
                .array([]),
                .number("6"),
                .array([
                    .string("deep")
                ])
            ])
        ]))
        XCTAssertEqual(remainder, ""[...])
    }
}
