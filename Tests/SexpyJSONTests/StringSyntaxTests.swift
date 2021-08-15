import XCTest
@testable import SexpyJSON

final class StringSyntaxTests: XCTestCase {
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

    func testQuotedWithEscapedQuoteToElement() throws {
        let (element, remainder) = buildParser().run(#""he\"llo""#)
        XCTAssertEqual(element, SexpyJSONElement.string(#"he\"llo"#))
        XCTAssertEqual(remainder, ""[...])
    }
}
