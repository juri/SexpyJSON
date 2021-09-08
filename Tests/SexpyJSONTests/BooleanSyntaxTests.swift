@testable import SexpyJSON
import XCTest

final class BooleanSyntaxTests: XCTestCase {
    func testTrue() throws {
        let (element, remainder) = buildParser().run("true")
        XCTAssertEqual(element, .boolean(true))
        XCTAssertEqual(remainder, ""[...])
    }

    func testFalse() throws {
        let (element, remainder) = buildParser().run("false")
        XCTAssertEqual(element, .boolean(false))
        XCTAssertEqual(remainder, ""[...])
    }
}
