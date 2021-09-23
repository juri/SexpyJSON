import Foundation
import FunctionDocExtractorCore
import SwiftSyntax

@main
enum Extractor {
    static func main() throws {
        let docResults = try extractFunctionDocumentation()
        let docs = try docResults
            .map { _, result in try result.get() }
            .sorted { $0.name < $1.name }
        for doc in docs {
            print("=== \(doc.name)")
            for part in doc.parts {
                print()
                switch part {
                case let .example(ex):
                    print("----")
                    print(ex.content)
                    print("----")
                    if let expect = ex.expectedReturn {
                        print()
                        print("----")
                        print("==> \(expect)")
                        print("----")
                    }
                case let .text(text):
                    print(text.content)
                }
            }
            print()
        }
    }
}
