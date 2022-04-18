@testable import SexpyJSON
import XCTest

final class CommentSyntaxTests: XCTestCase {
    func testSyntax() throws {
        let (_, remainder1): (Void?, Substring) = whitespaceOrComment.run("#  asdf")
        XCTAssertEqual(remainder1, ""[...])

        let (_, remainder2): (Void?, Substring) = whitespaceOrComment.run("#  asdf")
        XCTAssertEqual(remainder2, ""[...])

        let (_, remainder3): (Void?, Substring) = whitespaceOrComment.run("   asdf")
        XCTAssertEqual(remainder3, "asdf"[...])

        let (_, remainder4): (Void?, Substring) = whitespaceOrComment.run("   \n  asdf")
        XCTAssertEqual(remainder4, "asdf"[...])

        let (_, remainder5): (Void?, Substring) = whitespaceOrComment.run("# hello   \n  asdf")
        XCTAssertEqual(remainder5, "asdf"[...])
    }
}
