@testable import SexpyJSON
import XCTest

final class CombinatorTests: XCTestCase {
    func testCapturingLiteral() throws {
        let parser = capturingLiteral("foo")
        let (element, remainder) = parser.run("foo")
        XCTAssertEqual(element, "foo")
        XCTAssertEqual(remainder, ""[...])
    }

    func testFilter() throws {
        let parser = char.filter { $0 == "a" }
        let (element, remainder) = parser.run("foo")
        XCTAssertEqual(element, nil)
        XCTAssertEqual(remainder, "foo"[...])
    }
}
