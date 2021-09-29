import ArgumentParser
import Foundation
import FunctionDocExtractorCore

@main
@available(macOS 11.0, *)
struct DocBuilder: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Documentation builder for SexpyJSON.",
        subcommands: [Extract.self, BuildRaw.self, Build.self, UpdateGitHubPages.self]
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

@available(macOS 11.0, *)
struct UpdateGitHubPages: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "update-gh-pages",
        abstract: "Build processed language documentation and update the gh-pages branch."
    )

    @Option(help: "AsciiDoctor executable to use. Default: asciidoctor from path", transform: URL.init(fileURLWithPath:))
    var processor: URL?

    func run() throws {
        guard try runCapturingFromPath("git", args: ["status", "--porcelain"]).isEmpty else {
            throw errorExit("The working directory is not clean")
        }

        guard let branchName = try runCapturingFromPath("git", args: ["rev-parse", "--abbrev-ref", "HEAD"]).trimmedUTF8,
              !branchName.isEmpty
        else { throw errorExit("Failed to read current branch") }

        guard branchName == "main" else { throw errorExit("On \(branchName) branch, must be on main") }

        guard let repoRoot = try runCapturingFromPath("git", args: ["rev-parse", "--show-toplevel"]).trimmedUTF8,
              !repoRoot.isEmpty
        else {
            throw errorExit("Failed to read repository root")
        }

        print("🍒 Changing to repository root folder \(repoRoot)")

        guard FileManager.default.changeCurrentDirectoryPath(repoRoot) else {
            throw errorExit("Failed to change working directory to \(repoRoot)")
        }

        print("🍒 Switching to gh-pages branch")

        try runNoisyFromPath("git", args: ["switch", "--no-guess", "gh-pages"])

        print("🍒 Rebasing gh-pages on main")

        try runNoisyFromPath("git", args: ["rebase", "main"])
        let temp = try FileManager.default.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: URL(fileURLWithPath: ".", isDirectory: true),
            create: true
        )
        defer {
            do {
                try FileManager.default.removeItem(at: temp)
            } catch {
                print("Failed to erase temporary directory \(temp.path)", to: &StandardErrorOutputStream.stream)
            }
        }

        print("🍒 Generating documentation")

        let files = try createUnprocessed(target: temp)
        try processAsciiDoc(files: files, to: temp, with: self.processor)
        let htmlFiles = try FileManager.default.contentsOfDirectory(
            at: temp.appendingPathComponent("html"),
            includingPropertiesForKeys: nil,
            options: [.skipsSubdirectoryDescendants]
        )
        let docsFolder = URL(fileURLWithPath: "docs", isDirectory: true)
        print("🍒 Removing old documentation folder \(docsFolder.path)")
        try FileManager.default.removeItem(at: docsFolder)
        try FileManager.default.createDirectory(at: docsFolder, withIntermediateDirectories: true, attributes: nil)
        for file in htmlFiles {
            let outputName = file.lastPathComponent == "Index.html" ? "index.html" : file.lastPathComponent
            print("🍒 Copying documentation file \(outputName)")
            try FileManager.default.copyItem(at: file, to: docsFolder.appendingPathComponent(outputName))
        }

        print("🍒 Committing changes")
        try runNoisyFromPath("git", args: ["commit", "-m", "Updated documentation"])
    }
}

private func errorExit(_ message: String? = nil, _ code: Int32 = 1) -> Error {
    if let message = message {
        print(message, to: &StandardErrorOutputStream.stream)
    }
    return ExitCode(code)
}

extension Data {
    fileprivate var trimmedUTF8: String? {
        String(data: self, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
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

struct CommandErrorExit: Error {
    var code: Int
}

@discardableResult
@available(macOS 11.0, *)
private func runCapturingFromPath(_ command: String, args: [String], cwd: URL? = nil) throws -> Data {
    let stdout = Pipe()
    let proc = Process()
    proc.currentDirectoryURL = cwd
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/env", isDirectory: false)
    proc.arguments = [command] + args
    proc.standardOutput = stdout
    try proc.run()
    proc.waitUntilExit()
    guard proc.terminationStatus == 0 else {
        throw CommandErrorExit(code: Int(proc.terminationStatus))
    }
    let outputData = try stdout.fileHandleForReading.readToEnd()
    return outputData ?? Data()
}

@available(macOS 11.0, *)
private func runNoisyFromPath(_ command: String, args: [String], cwd: URL? = nil) throws {
    let proc = Process()
    proc.currentDirectoryURL = cwd
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/env", isDirectory: false)
    proc.arguments = [command] + args
    try proc.run()
    proc.waitUntilExit()
    guard proc.terminationStatus == 0 else {
        throw CommandErrorExit(code: Int(proc.terminationStatus))
    }
}

private final class StandardErrorOutputStream: TextOutputStream {
    func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }

    static var stream = StandardErrorOutputStream()
}
