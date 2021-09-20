import ArgumentParser
import Foundation
import SexpyJSON

@main
struct Executable: ParsableCommand {
    @Argument(help: "Expressions to evaluate")
    var expressions: [String]

    @Flag(inversion: .prefixedNo, help: "Pretty print JSON")
    var prettyPrint = true

    mutating func run() throws {
        let parser = SXPJParser()
        var evaluator = SXPJEvaluator()
        var output: SXPJOutputValue?
        for expression in self.expressions {
            let parsedExpr = try parser.parse(source: expression)
            output = try evaluator.evaluate(expression: parsedExpr)
        }

        guard let jsonOutput = output?.outputToJSONObject() else {
            print("null")
            return
        }

        let data = try JSONSerialization.data(withJSONObject: jsonOutput, options: self.writingOptions)
        let str = String(data: data, encoding: .utf8)!
        print(str)
    }

    var writingOptions: JSONSerialization.WritingOptions {
        var opts: JSONSerialization.WritingOptions = [.fragmentsAllowed]
        if self.prettyPrint {
            if #available(macOS 10.13, *) {
                opts.update(with: .sortedKeys)
            }
            opts.update(with: .prettyPrinted)
        }
        return opts
    }
}
