import Foundation
import FunctionDocExtractorCore

@main
enum DocBuilder {
    static func main() throws {
        print(try generateDocs())
    }
}
