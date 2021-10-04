import Foundation

public func generateDocs() throws -> String {
    let docResults = try extractFunctionDocumentation()
    let docs = try docResults
        .map { _, result in try result.get() }
    return generateDocs(for: docs)
}

public func generateDocs(for functionDocs: [FunctionDocumentation]) -> String {
    var lines = ["= SexpyJSON Standard Library", ""]
    let sections = Dictionary(grouping: functionDocs, by: section(for:))
    for section in Section.allSections {
        guard let sectionDocs = sections[section], !sectionDocs.isEmpty else { continue }
        let sortedDocs = sectionDocs.sorted { $0.name < $1.name }

        lines.append("== \(section.name)")
        lines.append("")
        for doc in sortedDocs {
            if let customID = doc.customID {
                lines.append("[#\(customID)]")
            }
            lines.append("=== \(doc.name)")
            for part in doc.parts {
                lines.append("")
                switch part {
                case let .example(ex):
                    lines.append("----")
                    lines.append(ex.content)
                    lines.append("----")
                    if let expect = ex.expectedReturn {
                        lines.append("")
                        lines.append("----")
                        lines.append("==> \(expect)")
                        lines.append("----")
                    }
                case let .text(text):
                    lines.append(text.content)
                }
            }
            lines.append("")
        }
    }
    return lines.joined(separator: "\n")
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
