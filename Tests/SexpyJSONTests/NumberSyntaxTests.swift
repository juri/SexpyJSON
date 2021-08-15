import XCTest
@testable import SexpyJSON

final class NumberSyntaxTests: XCTestCase {
    func testDigit() throws {
        let (element, remainder) = digit.run("1")
        XCTAssertEqual(element, "1")
        XCTAssertEqual(remainder, ""[...])
    }

    func testDigitWithReminder() throws {
        let (element, remainder) = digit.run("1 bang")
        XCTAssertEqual(element, "1")
        XCTAssertEqual(remainder, " bang"[...])
    }

    func testDigitToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("9")
        XCTAssertEqual(element, SexpyJSONElement.integer("9"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testUnsignedIntegerToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("123")
        XCTAssertEqual(element, SexpyJSONElement.integer("123"))
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testUnsignedIntegerToElementWithRemainder() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("123 zap")
        XCTAssertEqual(element, SexpyJSONElement.integer("123"))
        XCTAssertEqual(remainder, " zap"[...])
    }

    func testNegativeIntegerToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("-80")
        XCTAssertEqual(element, SexpyJSONElement.integer("-80"))
        XCTAssertEqual(remainder, ""[...])
    }
}
