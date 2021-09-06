/// `SXPJParser` is  the main entry point to SexpyJSON.
public struct SXPJParser {
    private let parser = buildParser()

    public func parse(source: String) throws -> SXPJParsedExpression {
        let (element, remainder) = self.parser.run(source)
        guard remainder.isEmpty else {
            throw SXPJError.unparsedInput(remainder)
        }
        guard let element = element else {
            throw SXPJError.parseFailure
        }
        return SXPJParsedExpression(expression: Expression(element: element))
    }
}

/// `SXPJParsedExpression` represents a parsed expression, waiting for evaluation.
/// Use the `evaluate` method to evaluate it directly, or create a `SXPJEvaluator`
/// if you intend to use one evaluator for multiple expressions.
public struct SXPJParsedExpression {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    func evaluate() throws -> SXPJOutputValue {
        var evaluator = SXPJEvaluator()
        return try evaluator.evaluate(expression: self)
    }
}

/// `SXPJEvaluator` evaluates one or more expressions. Use the same evaluator
/// for multiple `evaluate` calls if you want to keep shared definitions.
public struct SXPJEvaluator {
    private var context = Context.withBuiltins

    public mutating func evaluate(expression: SXPJParsedExpression) throws -> SXPJOutputValue {
        let originalContext = self.context

        do {
            let output = try evaluateToOutput(expression: expression.expression, mutating: &self.context)
            return SXPJOutputValue(outputValue: output)
        } catch let error as EvaluatorError {
            self.context = originalContext
            throw SXPJError.evaluationFailure(describe(error: error))
        } catch {
            self.context = originalContext
            throw SXPJError.other("Unexpected evaluation error: \(error)")
        }
    }
}

private func describe(error: EvaluatorError) -> String {
    switch error {
    case .badCallTarget:
        return "Trying to call a value that is not a function"
    case .badExpressionType:
        return "Bad expression type"
    case let .badParameterList(_, message):
        return "Bad parameter list: \(message)"
    case let .missingValue(name):
        return "Missing value: \(name)"
    case .uncalledFunction:
        return "Found an uncalled function in output"
    }
}

public enum SXPJOutputValue: Equatable {
    case string(String)
    case number(Double)
    case array([SXPJOutputValue])
    case object([SXPJOutputObjectMember])
    case boolean(Bool)
    case null

    init(outputValue: OutputValue) {
        switch outputValue {
        case let .string(string):
            self = .string(string)
        case let .number(double):
            self = .number(double)
        case let .array(array):
            self = .array(array.map(SXPJOutputValue.init(outputValue:)))
        case let .object(array):
            self = .object(array.map(SXPJOutputObjectMember.init(outputObjectMember:)))
        case let .boolean(bool):
            self = .boolean(bool)
        case .null:
            self = .null
        }
    }

    public func outputToJSONObject() -> Any? {
        switch self {
        case let .number(n): return n
        case .null: return nil
        case let .string(s): return s
        case let .boolean(b): return b
        case let .array(a): return a.map { $0.outputToJSONObject() }
        case let .object(members):
            let pairs = members.map { member in
                (member.name, member.value.outputToJSONObject())
            }
            return Dictionary(pairs, uniquingKeysWith: { $1 })
        }
    }
}

public struct SXPJOutputObjectMember: Equatable {
    public var name: String
    public var value: SXPJOutputValue

    init(outputObjectMember: OutputObjectMember) {
        self.name = outputObjectMember.name
        self.value = SXPJOutputValue(outputValue: outputObjectMember.value)
    }
}


/// `SXPJError` enumerates the errors that SexpyJSON may throw.
public enum SXPJError: Error {
    case evaluationFailure(String)
    case other(String)
    case parseFailure
    case unparsedInput(Substring)
}

