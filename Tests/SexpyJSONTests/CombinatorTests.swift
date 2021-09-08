@testable import SexpyJSON
import XCTest

final class CombinatorTests: XCTestCase {
    func testCapturingLiteral() throws {
        let parser = capturingLiteral("foo")
        let (element, remainder) = parser.run("foo")
        XCTAssertEqual(element, "foo")
        XCTAssertEqual(remainder, ""[...])
    }
}
