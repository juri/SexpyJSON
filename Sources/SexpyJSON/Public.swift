/// `SXPJParser` is  the main entry point to SexpyJSON.
public struct SXPJParser {
    private let parser = buildParser()

    public init() {}

    /// Parse an expression represented as a String.
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
/// Use the `evaluate` method to evaluate it directly, or create a ``SXPJEvaluator``
/// if you intend to use one evaluator for multiple expressions.
///
/// You can evaluate the same `SXPJParsedExpression` multiple times.
public struct SXPJParsedExpression {
    let expression: Expression

    init(expression: Expression) {
        self.expression = expression
    }

    /// Evaluate the expression using a new evaluator.
    ///
    /// Alternatively allocate a ``SXPJEvaluator`` yourself and use it
    /// for evaluating `SXPJParsedExpression` values.
    public func evaluate() throws -> SXPJOutputValue {
        var evaluator = SXPJEvaluator()
        return try evaluator.evaluate(expression: self)
    }
}

/// `SXPJEvaluator` evaluates one or more expressions. Use the same evaluator
/// for multiple `evaluate` calls if you want to keep shared definitions.
public struct SXPJEvaluator {
    private var context = Context.withBuiltins

    public init() {}

    /// Inject a string into the namespace of the evaluator.
    public func set(value: String, for key: String) {
        self.context.set(value: .string(value), for: Symbol(key))
    }

    /// Inject an integer into the namespace of the evaluator.
    public func set(value: Int, for key: String) {
        self.context.set(value: .integer(value), for: Symbol(key))
    }

    /// Inject a double into the namespace of the evaluator.
    public func set(value: Double, for key: String) {
        self.context.set(value: .double(value), for: Symbol(key))
    }

    /// Inject a boolean into the namespace of the evaluator.
    public func set(value: Bool, for key: String) {
        self.context.set(value: .boolean(value), for: Symbol(key))
    }

    /// Inject a null into the namespace of the evaluator.
    public func setNull(for key: String) {
        self.context.set(value: .null, for: Symbol(key))
    }

    /// Inject an array into the namespace of the evaluator.
    ///
    /// The array will be stored as is. Depending on your usage pattern,
    /// ``setAndPreconvert(value:for:)-66zs9`` may be more efficient.
    public func set(value: [Any], for key: String) {
        self.context.set(value: .nativeArray(value), for: Symbol(key))
    }

    /// Inject an array into the namespace of the evaluator and preconvert
    /// it into an internal representation.
    ///
    /// If you only intend to access a small subset of elements, ``set(value:for:)-5bb6k``
    /// may be more efficient.
    public func setAndPreconvert(value: [Any], for key: String) throws {
        try self.context.set(value: IntermediateValue.tryInitArray(nativeValue: value), for: Symbol(key))
    }

    /// Inject a value-returning function into the namespace of the evaluator.
    public func set(value: @escaping ([SXPJOutputValue]) throws -> Any?, for key: String) {
        self.context.set(value: .callable(.nativeFunction(NativeFunction(f: value))), for: Symbol(key))
    }

    /// Inject a Void-returning functioninto the namespace of the evaluator.
    public func set(value: @escaping ([SXPJOutputValue]) throws -> Void, for key: String) {
        let nf = NativeFunction {
            try value($0)
            return .none
        }
        self.context.set(value: .callable(.nativeFunction(nf)), for: Symbol(key))
    }

    /// Inject a dictionary into the namespace of the evaluator.
    ///
    /// The dictionary will be stored as is. Depending on your usage pattern,
    /// ``setAndPreconvert(value:for:)-888la`` may be more efficient.
    public func set(value: [String: Any], for key: String) {
        self.context.set(value: .dict(value), for: Symbol(key))
    }

    /// Inject a dictionary into the namespace of the evaluator and convert it into the
    /// internal representation.
    ///
    /// In some cases, storing the dictionary as is with ``set(value:for:)-9bdw2``
    /// may be more efficient.
    public func setAndPreconvert(value: [String: Any], for key: String) throws {
        try self.context.set(value: IntermediateValue.tryInitObject(nativeValue: value), for: Symbol(key))
    }

    /// Evaluate the expression and return any value.
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

/// `SXPJOutputValue` represents a JSON value returned from the SexpyJSON evaluator.
public enum SXPJOutputValue: Equatable {
    /// A JSON string.
    case string(String)
    /// A JSON number. Numbers in JSON are always Doubles.
    case number(Double)
    /// A JSON array consisting of other `SXOJOutputValue`s.
    case array([SXPJOutputValue])
    /// A JSON object. It is represented as a list of fields, in the same order as they originally were.
    case object([SXPJOutputObjectMember])
    /// A JSON boolean.
    case boolean(Bool)
    /// A null value.
    case null

    /// Converts the `SXPJOutputValue` to an object suitable for use with `JSONSerialization`.
    /// A `SXPJOutputValue.null` will cause `nil` to be returned.
    public func outputToJSONObject() -> Any? {
        switch self {
        case let .number(n): return n
        case .null: return nil
        case let .string(s): return s
        case let .boolean(b): return b
        case let .array(a): return a.map { $0.outputToJSONObject() }
        case let .object(members):
            let pairs = members.compactMap { member -> (String, Any)? in
                guard let valueOb = member.value.outputToJSONObject() else { return nil }
                return (member.name, valueOb)
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

/// `SXPJOutputObjectMember` is a member of a JSON object.
public struct SXPJOutputObjectMember: Equatable {
    public var name: String
    public var value: SXPJOutputValue

    public init(name: String, value: SXPJOutputValue) {
        self.name = name
        self.value = value
    }
}

/// `SXPJError` enumerates the errors that SexpyJSON may throw.
public enum SXPJError: Error {
    case evaluationFailure(String)
    case other(String)
    case parseFailure
    case unparsedInput(Substring)
}
