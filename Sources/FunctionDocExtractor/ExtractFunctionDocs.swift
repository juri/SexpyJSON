import Foundation
import FunctionDocExtractorCore
import SwiftSyntax

@main
enum Extractor {
    static func main() throws {
        let docResults = try extractFunctionDocumentation()
        dump(docResults)
    }
}
