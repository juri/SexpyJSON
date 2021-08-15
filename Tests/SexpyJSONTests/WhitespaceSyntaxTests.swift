import XCTest
@testable import SexpyJSON

final class WhitespaceSyntaxTests: XCTestCase {
    func testEmpty() throws {
        let (_, remainder): (Void?, Substring) = whitespace.run("")
        XCTAssertEqual(remainder, ""[...])
    }

    func testNonEmpty() throws {
        let (_, remainder): (Void?, Substring) = whitespace.run("  asdf")
        XCTAssertEqual(remainder, "asdf"[...])
    }
}

