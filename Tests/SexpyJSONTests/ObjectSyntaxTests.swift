import XCTest
@testable import SexpyJSON

final class ObjectSyntaxTests: XCTestCase {
    func testEmpty() throws {
        let (element, remainder) = buildParser().run(#"{}"#)
        XCTAssertEqual(element, SexpyJSONElement.object([]))
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testOneStringField() throws {
        let (element, remainder) = buildParser().run(#"{"f1": "v1"}"#)
        XCTAssertEqual(element, SexpyJSONElement.object([.init(name: "f1", value: .string("v1"))]))
        XCTAssertEqual(remainder, ""[...])
    }

    func testOneIntegerField() throws {
        let (element, remainder) = buildParser().run(#"{"f1": 100}"#)
        XCTAssertEqual(element, SexpyJSONElement.object([.init(name: "f1", value: .integer(100))]))
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testTwoFields() throws {
        let (element, remainder) = buildParser().run(#"{"f1": "v1", "f2": 2}"#)
        XCTAssertEqual(
            element,
            SexpyJSONElement.object([
                .init(name: "f1", value: .string("v1")),
                .init(name: "f2", value: .integer(2))
            ])
        )
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testCompoundFields() throws {
        let (element, remainder) = buildParser().run(#"{"f1": [1, {"n1": {"n1n1": "n1n1v"}}], "f2": {"n2": {}}}"#)
        XCTAssertEqual(
            element,
            SexpyJSONElement.object([
                .init(name: "f1", value: .array([
                    .integer(1),
                    .object([
                        .init(name: "n1", value: .object([
                            .init(name: "n1n1", value: .string("n1n1v"))
                        ]))
                    ])
                ])),
                .init(name: "f2", value: .object([
                    .init(name: "n2", value: .object([]))
                ]))
            ])
        )
        XCTAssertEqual(remainder, ""[...])

    }
}
