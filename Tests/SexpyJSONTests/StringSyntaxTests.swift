@testable import SexpyJSON
import XCTest

final class StringSyntaxTests: XCTestCase {
    func testEmpty() throws {
        let (element, remainder) = quoted.run("\"\"")
        XCTAssertEqual(try XCTUnwrap(element), "")
        XCTAssertEqual(remainder, ""[...])
    }

    func testQuoted() throws {
        let (element, remainder) = quoted.run(#""hello""#)
        XCTAssertEqual(element, "hello")
        XCTAssertEqual(remainder, ""[...])
    }

    func testQuotedWithEscapedQuote() throws {
        let (element, remainder) = quoted.run(#""he\"llo""#)
        XCTAssertEqual(element, #"he\"llo"#)
        XCTAssertEqual(remainder, ""[...])
    }

    func testQuotedWithEscapedCharacters() throws {
        let (element, remainder) = quoted.run(#""he\\l\nlo""#)
        XCTAssertEqual(element, #"he\\l\nlo"#)
        XCTAssertEqual(remainder, ""[...])
    }

    func testQuotedWithEscapedQuoteToElement() throws {
        let (element, remainder) = buildParser().run(#""he\"llo""#)
        XCTAssertEqual(element, SexpyJSONElement.string(#"he\"llo"#))
        XCTAssertEqual(remainder, ""[...])
    }
}
