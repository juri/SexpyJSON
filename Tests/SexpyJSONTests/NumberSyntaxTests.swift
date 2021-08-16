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
        XCTAssertEqual(element, SexpyJSONElement.number("9"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testUnsignedIntegerToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("123")
        XCTAssertEqual(element, SexpyJSONElement.number("123"))
        XCTAssertEqual(remainder, ""[...])
    }
    
    func testUnsignedIntegerToElementWithRemainder() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("123 zap")
        XCTAssertEqual(element, SexpyJSONElement.number("123"))
        XCTAssertEqual(remainder, " zap"[...])
    }

    func testNegativeIntegerToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("-80")
        XCTAssertEqual(element, SexpyJSONElement.number("-80"))
        XCTAssertEqual(remainder, ""[...])
    }
    
    // MARK: Fractionals

    func testFractionalToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("101.010")
        XCTAssertEqual(element, SexpyJSONElement.number("101.010"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testNegativeFractionalToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("-80.9")
        XCTAssertEqual(element, SexpyJSONElement.number("-80.9"))
        XCTAssertEqual(remainder, ""[...])
    }
    
    // MARK: Exponents

    func testExponentToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("101e10")
        XCTAssertEqual(element, SexpyJSONElement.number("101e10"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testNegativeExponentToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("-80E-9")
        XCTAssertEqual(element, SexpyJSONElement.number("-80E-9"))
        XCTAssertEqual(remainder, ""[...])
    }
    
    // MARK: Fractionals and exponents
    
    func testFractionalAndExponentToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("101.010e10")
        XCTAssertEqual(element, SexpyJSONElement.number("101.010e10"))
        XCTAssertEqual(remainder, ""[...])
    }

    func testFractionalAndNegativeExponentToElement() throws {
        let parser = buildParser()
        let (element, remainder) = parser.run("-80.08E-9")
        XCTAssertEqual(element, SexpyJSONElement.number("-80.08E-9"))
        XCTAssertEqual(remainder, ""[...])
    }
}
