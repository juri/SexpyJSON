import Foundation
import FunctionDocExtractorCore
import SwiftSyntax

@main
enum Extractor {
    static func main() throws {
        let docResults = try extractFunctionDocumentation()
        let docs = try docResults
            .map { _, result in try result.get() }
        let sections = Dictionary(grouping: docs, by: section(for:))
        for section in Section.allSections {
            guard let sectionDocs = sections[section], !sectionDocs.isEmpty else { continue }
            let sortedDocs = sectionDocs.sorted { $0.name < $1.name }

            print("=== \(section.name)")
            print()
            for doc in sortedDocs {
                print("==== \(doc.name)")
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
}

private func section(for doc: FunctionDocumentation) -> Section {
    doc.section.flatMap { Section.section(for: $0) } ?? Section.defaultSection
}

private struct Section: Equatable, Hashable {
    let id: String
    let name: String
    let priority: Int

    static let specialForms = Section(id: "specialforms", name: "Special Forms", priority: 1)
    static let functions = Section(id: "functions", name: "Functions", priority: 2)

    static let defaultSection = functions
    static let allSections = [specialForms, functions]

    static func section(for id: String) -> Section? {
        self.allSections.first(where: { $0.id == id })
    }
}
