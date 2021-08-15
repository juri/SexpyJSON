import XCTest
@testable import SexpyJSON

final class NullSyntaxTests: XCTestCase {
    func testNull() throws {
        let (element, remainder) = buildParser().run("null")
        XCTAssertEqual(element, SexpyJSONElement.null)
        XCTAssertEqual(remainder, ""[...])
    }
}
