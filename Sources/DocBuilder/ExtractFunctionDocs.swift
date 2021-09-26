import Foundation
import FunctionDocExtractorCore

@main
enum Extractor {
    static func main() throws {
        print(try generateDocs())
    }
}
