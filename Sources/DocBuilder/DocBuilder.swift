import ArgumentParser
import Foundation
import FunctionDocExtractorCore

@main
@available(macOS 10.13, *)
struct DocBuilder: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Documentation builder for SexpyJSON.",
        subcommands: [Extract.self, BuildRaw.self, Build.self]
    )
}

struct Extract: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Extract function documentation and print to standard output."
    )

    func run() throws {
        print(try generateDocs())
    }
}

struct BuildRaw: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Build unprocessed language documentation to a target folder."
    )

    @Argument(help: "Target folder", transform: TargetPath.init(argument:))
    var target: TargetPath

    func run() throws {
        try createUnprocessed(target: self.target.name)
    }
}

@available(macOS 10.13, *)
struct Build: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Build processed language documentation to a target folder."
    )

    @Option(help: "AsciiDoctor executable to use. Default: asciidoctor from path", transform: URL.init(fileURLWithPath:))
    var processor: URL?

    @Argument(help: "Target folder", transform: TargetPath.init(argument:))
    var target: TargetPath

    func run() throws {
        let files = try createUnprocessed(target: self.target.name)
        try processAsciiDoc(files: files, to: self.target.name, with: self.processor)
    }
}

@discardableResult
private func createUnprocessed(target: URL) throws -> [URL] {
    let rawFolder = target.appendingPathComponent("raw", isDirectory: true)
    try FileManager.default.createDirectory(at: rawFolder, withIntermediateDirectories: true, attributes: nil)
    let docFiles = try FileManager.default.contentsOfDirectory(
        at: URL(fileURLWithPath: "Documentation", isDirectory: true),
        includingPropertiesForKeys: nil,
        options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
    )
    let copyTargetFiles = docFiles.map {
        rawFolder.appendingPathComponent($0.lastPathComponent, isDirectory: false)
    }
    for (docFile, targetFile) in zip(docFiles, copyTargetFiles) {
        try FileManager.default.copyItem(at: docFile, to: targetFile)
    }

    let functionsTargetFile = rawFolder.appendingPathComponent("Functions.adoc", isDirectory: false)
    let functionDocs = try generateDocs()
    FileManager.default.createFile(
        atPath: functionsTargetFile.path,
        contents: Data(functionDocs.utf8),
        attributes: nil
    )
    return copyTargetFiles + [functionsTargetFile]
}

@available(macOS 10.13, *)
private func processAsciiDoc(files: [URL], to folder: URL, with processor: URL?) throws {
    let proc = Process()
    let outputFolder = folder.appendingPathComponent("html", isDirectory: true)
    try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true, attributes: nil)

    let (execURL, argsPrefix) = processor.map {
        ($0, [])
    } ?? (URL(fileURLWithPath: "/usr/bin/env", isDirectory: false), ["asciidoctor"])

    proc.currentDirectoryURL = outputFolder
    proc.executableURL = execURL
    proc.arguments = argsPrefix + files.map(\.path) + ["-D", "."]
    try proc.run()
    proc.waitUntilExit()
}

struct TargetPath {
    var name: URL
}

extension TargetPath {
    init(argument: String) throws {
        let url = URL(fileURLWithPath: argument, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        self.name = url
    }
}
