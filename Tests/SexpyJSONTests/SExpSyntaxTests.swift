@testable import SexpyJSON
import XCTest

final class SExpSyntaxTests: XCTestCase {
    func testExpressionEmpty() throws {
        let (element, remainder) = buildParser().run(#"()"#)
        XCTAssertEqual(element, SexpyJSONElement.sexp(.empty))
        XCTAssertEqual(remainder, ""[...])
    }

    func testExpressionEmptySpace() throws {
        let (element, remainder) = buildParser().run(#"(   )"#)
        XCTAssertEqual(element, SexpyJSONElement.sexp(.empty))
        XCTAssertEqual(remainder, ""[...])
    }

    func testExpressionWithTargetNoParams() throws {
        let (element, remainder) = buildParser().run(#"(target)"#)
        XCTAssertEqual(element, SexpyJSONElement.sexp(.call(.init(target: .symbol(.init("target")), params: []))))
        XCTAssertEqual(remainder, ""[...])
    }

    func testSymbolStartingWithUnderscore() throws {
        let (element, remainder) = buildParser().run(#"(_target)"#)
        XCTAssertEqual(element, SexpyJSONElement.sexp(.call(.init(target: .symbol(.init("_target")), params: []))))
        XCTAssertEqual(remainder, ""[...])
    }

    func testSymbolWithSpecialCharacters() throws {
        let (element, remainder) = buildParser().run(#"(t-a*r!g+e$t?)"#)
        XCTAssertEqual(element, SexpyJSONElement.sexp(.call(.init(target: .symbol(.init("t-a*r!g+e$t?")), params: []))))
        XCTAssertEqual(remainder, ""[...])
    }

    func testExpressionWithTargetAndStringParams() throws {
        let (element, remainder) = buildParser().run(#"(target "p1" "p2")"#)
        XCTAssertEqual(
            try XCTUnwrap(element),
            SexpyJSONElement.sexp(.call(.init(target: .symbol(.init("target")), params: [
                .element(.string("p1")),
                .element(.string("p2")),
            ])))
        )
        XCTAssertEqual(remainder, ""[...])
    }

    func testExpressionWithTargetAndSymbolParams() throws {
        let (element, remainder) = buildParser().run(#"(target p1 p2)"#)
        XCTAssertEqual(
            element,
            SexpyJSONElement.sexp(.call(.init(target: .symbol(.init("target")), params: [
                .symbol(.init("p1")),
                .symbol(.init("p2")),
            ])))
        )
        XCTAssertEqual(remainder, ""[...])
    }

    func testNested() throws {
        let (element, remainder) = buildParser().run(#"(target {"a": (list 1 2 3)})"#)
        XCTAssertEqual(
            element,
            SexpyJSONElement.sexp(.call(.init(target: .symbol(.init("target")), params: [
                .element(.object([
                    .init(
                        name: "a",
                        value: .sexp(.call(
                            .init(target: .symbol(.init("list")), params: [
                                .element(.number("1")),
                                .element(.number("2")),
                                .element(.number("3")),
                            ])
                        ))
                    ),
                ])),

            ])))
        )
        XCTAssertEqual(remainder, ""[...])
    }
}
