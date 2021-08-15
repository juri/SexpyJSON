import XCTest
@testable import SexpyJSON

final class CombinatorTests: XCTestCase {
    func testCapturingLiteral() throws {
        let parser = capturingLiteral("foo")
        let (element, remainder) = parser.run("foo")
        XCTAssertEqual(element, "foo")
        XCTAssertEqual(remainder, ""[...])
    }
}

