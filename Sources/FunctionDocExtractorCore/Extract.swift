import Foundation
import SwiftSyntax
import SwiftSyntaxParser

/// `extractFunctionDocumentation` extracts documentation for SexpyJSON
/// functions.
public func extractFunctionDocumentation() throws -> [(URL, Result<FunctionDocumentation, FunctionDocumentationParseError>)] {
    try extractFunctionDocumentation(sources: try findFunctionSources())
}

public func extractFunctionDocumentation(
    sources: [URL]
) throws -> [(URL, Result<FunctionDocumentation, FunctionDocumentationParseError>)] {
    sources.flatMap { url -> [(URL, Result<FunctionDocumentation, FunctionDocumentationParseError>)] in
        let docs = findComments(url: url)
        return docs.map { (url, $0) }
    }
}

/// `FunctionDocumentation` stores documentation for one function, identified by `name`.
public struct FunctionDocumentation {
    public var name: String
    public var section: String?
    public var customID: String?
    public var parts: [FunctionDocumentationPart]
}

/// `FunctionDocumentationPart` is either documentation text or example.
public enum FunctionDocumentationPart {
    case example(FunctionDocumentationExample)
    case text(FunctionDocumentationText)
}

/// `FunctionDocumentationExample` is an example code snippet with an optional expected result.
public struct FunctionDocumentationExample {
    public var content: String
    public var expectedReturn: String?
}

/// `FunctionDocumentationText` is documentation text. It does not care what format you are using.
public struct FunctionDocumentationText {
    public var content: String
}

/// `FunctionDocumentationParseError` enumerates the various failures the documentation
/// parser may encounter.
public enum FunctionDocumentationParseError: Error {
    case badFundocSyntax(String)
    case indentationError
    case missingName
    case nonEmptyLastLine
    case orphanCustomID
    case orphanExample
    case orphanExpect
    case orphanSection
    case orphanText
    case parseError(Error)
}

private enum FundocBlock {
    case customID(String)
    case name(String)
    case example(String)
    case expect(String)
    case section(String)
    case text(String)
}

extension FundocBlock {
    static func parse(comment: String) -> Result<FundocBlock?, FunctionDocumentationParseError> {
        let lines = comment.split(separator: "\n")
        guard let first = lines.first?.drop(while: \.isWhitespace) else { return .success(nil) }
        guard first.starts(with: "/* ") else { return .success(nil) }
        let trimmedFirst = first.dropFirst(2).trimmingCharacters(in: .whitespaces)
        guard trimmedFirst.starts(with: "fundoc ") else { return .success(nil) }

        guard lines.last?.trimmingCharacters(in: .whitespaces) == "*/" else { return .failure(.nonEmptyLastLine) }
        guard let content = trimLineIndents(lines.dropFirst().dropLast()) else { return .failure(.indentationError) }
        let contentString = String(content.joined(separator: "\n"))
        let restOfFirst = trimmedFirst.dropFirst(7)
        switch restOfFirst {
        case "id": return .success(.customID(contentString))
        case "name": return .success(.name(contentString))
        case "example": return .success(.example(contentString))
        case "expect": return .success(.expect(contentString))
        case "section": return .success(.section(contentString))
        case "text": return .success(.text(contentString))
        default: return .failure(.badFundocSyntax(String(restOfFirst)))
        }
    }
}

private func trimLineIndents(_ lines: [Substring]) -> [Substring]? {
    guard let first = lines.first else { return nil }
    let firstIndent = first.prefix(while: \.isWhitespace).count
    var output = [Substring]()
    output.reserveCapacity(lines.count)
    for line in lines {
        let linePrefix = line.prefix(firstIndent)
        guard linePrefix.allSatisfy(\.isWhitespace) else { return nil }
        output.append(line.dropFirst(firstIndent))
    }
    return output
}

private class CommentFinder: SyntaxRewriter {
    var blocks: [Result<FundocBlock, FunctionDocumentationParseError>] = []

    override func visit(_ token: TokenSyntax) -> Syntax {
        for trivia in token.leadingTrivia {
            switch trivia {
            case let .blockComment(comment):
                let parseResult = FundocBlock.parse(comment: comment)
                switch parseResult {
                case let .success(.some(block)):
                    self.blocks.append(.success(block))
                case .success(.none):
                    break
                case let .failure(err):
                    self.blocks.append(.failure(err))
                }
            default:
                break
            }
        }

        return .init(token)
    }
}

private func findComments(url: URL) -> [Result<FunctionDocumentation, FunctionDocumentationParseError>] {
    let sourceFile: SourceFileSyntax
    do {
        sourceFile = try SyntaxParser.parse(url)
    } catch {
        return [.failure(.parseError(error))]
    }
    let commentFinder = CommentFinder()
    _ = commentFinder.visit(sourceFile)
    let acc = [Result<FunctionDocumentation, FunctionDocumentationParseError>]()
    let docs = commentFinder.blocks.reduce(into: acc) { acc, result in
        switch (acc.last, result) {
        case let (.none, .success(.name(name))):
            acc.append(.success(.init(name: name, parts: [])))
        case (.none, .success):
            acc.append(.failure(.missingName))
        case let (.some, .success(.name(name))):
            acc.append(.success(.init(name: name, parts: [])))

        case (.some(.success(var doc)), let .success(.section(section))):
            doc.section = section
            acc = acc.dropLast() + [.success(doc)]
        case (.some(.failure), .success(.section)):
            acc.append(.failure(.orphanSection))

        case (.some(.success(var doc)), let .success(.customID(customID))):
            doc.customID = customID
            acc = acc.dropLast() + [.success(doc)]
        case (.some(.failure), .success(.customID)):
            acc.append(.failure(.orphanCustomID))

        case (.some(.success(var doc)), let .success(.expect(expect))):
            switch doc.parts.last {
            case var .example(ex):
                ex.expectedReturn = expect
                doc.parts = doc.parts.dropLast() + [.example(ex)]
                acc = acc.dropLast() + [.success(doc)]
            default:
                acc.append(.failure(.orphanExpect))
            }
        case (.some(.failure), .success(.expect)):
            acc.append(.failure(.orphanExpect))

        case (.some(.success(var doc)), let .success(.example(example))):
            doc.parts.append(.example(.init(content: example, expectedReturn: nil)))
            acc = acc.dropLast() + [.success(doc)]
        case (.some(.failure), .success(.example)):
            acc.append(.failure(.orphanExample))

        case (.some(.success(var doc)), let .success(.text(text))):
            doc.parts.append(.text(.init(content: text)))
            acc = acc.dropLast() + [.success(doc)]
        case (.some(.failure), .success(.text)):
            acc.append(.failure(.orphanText))

        case let (_, .failure(err)):
            acc.append(.failure(err))
        }
    }
    return docs
}

private func findFunctionSources() throws -> [URL] {
    let url = URL(fileURLWithPath: "Sources/SexpyJSON/Functions", isDirectory: true)
    let files = try FileManager.default.contentsOfDirectory(atPath: "Sources/SexpyJSON/Functions")
    let fileURLs = files.map(url.appendingPathComponent(_:))
    return fileURLs
}
