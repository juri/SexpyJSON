import XCTest
@testable import SexpyJSON

final class SExpSyntaxTests: XCTestCase {
    func testExpressionWithTargetNoParams() throws {
        let (element, remainder) = buildParser().run(#"(target)"#)
        XCTAssertEqual(element, SexpyJSONElement.sexp(.init(target: .symbol(.name("target")), params: [])))
        XCTAssertEqual(remainder, ""[...])
    }

    func testExpressionWithTargetAndStringParams() throws {
        let (element, remainder) = buildParser().run(#"(target "p1" "p2")"#)
        XCTAssertEqual(
            element,
            SexpyJSONElement.sexp(.init(target: .symbol(.name("target")), params: [
                .element(.string("p1")),
                .element(.string("p2")),
            ]))
        )
        XCTAssertEqual(remainder, ""[...])
    }

    func testExpressionWithTargetAndSymbolParams() throws {
        let (element, remainder) = buildParser().run(#"(target p1 p2)"#)
        XCTAssertEqual(
            element,
            SexpyJSONElement.sexp(.init(target: .symbol(.name("target")), params: [
                .symbol(.name("p1")),
                .symbol(.name("p2"))
            ]))
        )
        XCTAssertEqual(remainder, ""[...])
    }
}
