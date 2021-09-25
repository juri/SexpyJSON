@testable import SexpyJSON
import XCTest

final class SymbolSyntaxTests: XCTestCase {
    func testRestrictedPlus() throws {
        let (element, remainder) = symbol.run(#"+"#)
        XCTAssertEqual(element, .init("+"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testRestrictedMinus() throws {
        let (element, remainder) = symbol.run(#"-"#)
        XCTAssertEqual(element, .init("-"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testSpecials() throws {
        let (element, remainder) = symbol.run(#"*&/@"#)
        XCTAssertEqual(element, .init("*&/@"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testAlphanumerics() throws {
        let (element, remainder) = symbol.run(#"asdf32Foo"#)
        XCTAssertEqual(element, .init("asdf32Foo"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testParens() throws {
        let (element, remainder) = symbol.run(#"()"#)
        XCTAssertEqual(element, .none)
        XCTAssertEqual(remainder, "()"[...])
    }
}
