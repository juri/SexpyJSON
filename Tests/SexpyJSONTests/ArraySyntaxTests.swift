import XCTest
@testable import SexpyJSON

final class ArraySyntaxTests: XCTestCase {
    func testEmpty() throws {
        let (element, remainder) = buildParser().run("[]")
        XCTAssertEqual(element, SexpyJSONElement.array([]))
        XCTAssertEqual(remainder, ""[...])
    }

    func testStringsNumbers() throws {
        let (element, remainder) = buildParser().run(#"[1, "first", 42, "second"]"#)
        let actualElement = try XCTUnwrap(element)
        XCTAssertEqual(actualElement, SexpyJSONElement.array([
            .integer(1),
            .string("first"),
            .integer(42),
            .string("second")
        ]))
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testNested() throws {
        let (element, remainder) = buildParser().run(#"[1, "first", 42, "second", [11, [], 6, ["deep"]]]"#)
        let actualElement = try XCTUnwrap(element)
        XCTAssertEqual(actualElement, SexpyJSONElement.array([
            .integer(1),
            .string("first"),
            .integer(42),
            .string("second"),
            .array([
                .integer(11),
                .array([]),
                .integer(6),
                .array([
                    .string("deep")
                ])
            ])
        ]))
        XCTAssertEqual(remainder, ""[...])
    }
}
