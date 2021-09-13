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

    public func set(value: String, for key: String) {
        self.context.set(value: .string(value), for: Symbol(key))
    }

    public func set(value: Int, for key: String) {
        self.context.set(value: .integer(value), for: Symbol(key))
    }

    public func set(value: Double, for key: String) {
        self.context.set(value: .double(value), for: Symbol(key))
    }

    public func set(value: Bool, for key: String) {
        self.context.set(value: .boolean(value), for: Symbol(key))
    }

    public func setNull(for key: String) {
        self.context.set(value: .null, for: Symbol(key))
    }

    public func set(array: [Any], for key: String) {
        self.context.set(value: .nativeArray(array), for: Symbol(key))
    }

    public func setPreconvert(array: [Any], for key: String) throws {
        try self.context.set(value: IntermediateValue.tryInitArray(nativeValue: array), for: Symbol(key))
    }

    public func set(value: @escaping ([SXPJOutputValue]) throws -> Any?, for key: String) {
        self.context.set(value: .callable(.nativeFunction(NativeFunction(f: value))), for: Symbol(key))
    }

    public func set(value: @escaping ([SXPJOutputValue]) throws -> Void, for key: String) {
        let nf = NativeFunction {
            try value($0)
            return .none
        }
        self.context.set(value: .callable(.nativeFunction(nf)), for: Symbol(key))
    }

    @discardableResult
    public mutating func evaluate(expression: SXPJParsedExpression) throws -> SXPJOutputValue {
        let originalContext = self.context

        do {
            return try evaluateToOutput(expression: expression.expression, mutating: &self.context)
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
    case let .badFunctionParameters(params, message):
        return "Bad parameter list (\(params)): \(message)"
    case let .badParameterList(_, message):
        return "Bad parameter list: \(message)"
    case let .divisionByZero(divident):
        return "Division by zero: \(divident)/0"
    case let .missingValue(name):
        return "Missing value: \(name)"
    case .uncalledFunction:
        return "Found an uncalled function in output"
    case let .unrecognizedNativeType(value):
        return "Unrecognized native type: \(String(describing: value))"
    }
}

public enum SXPJOutputValue: Equatable {
    case string(String)
    case number(Double)
    case array([SXPJOutputValue])
    case object([SXPJOutputObjectMember])
    case boolean(Bool)
    case null

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

extension SXPJOutputValue {
    public var string: String? {
        guard case let .string(s) = self else { return nil }
        return s
    }

    public var number: Double? {
        guard case let .number(n) = self else { return nil }
        return n
    }

    public var array: [SXPJOutputValue]? {
        guard case let .array(a) = self else { return nil }
        return a
    }

    public var object: [SXPJOutputObjectMember]? {
        guard case let .object(o) = self else { return nil }
        return o
    }

    public var boolean: Bool? {
        guard case let .boolean(b) = self else { return nil }
        return b
    }

    public var isNull: Bool {
        guard case .null = self else { return false }
        return true
    }
}

public struct SXPJOutputObjectMember: Equatable {
    public var name: String
    public var value: SXPJOutputValue
}

/// `SXPJError` enumerates the errors that SexpyJSON may throw.
public enum SXPJError: Error {
    case evaluationFailure(String)
    case other(String)
    case parseFailure
    case unparsedInput(Substring)
}
