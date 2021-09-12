struct Context {
    var namespace: Namespace

    func value(for symbol: Symbol) throws -> IntermediateValue {
        try self.namespace[symbol]
    }

    func set(value: IntermediateValue, for key: Symbol) {
        self.namespace.overrideName(key, value: value)
    }

    func wrap(names: [Symbol: IntermediateValue]) -> Context {
        Context(namespace: .init(names: names, wrappedNamespace: self.namespace))
    }

    static let withBuiltins = Context(namespace: .init(names: builtins, wrappedNamespace: nil))
    static let empty = Context(namespace: .empty)
}

final class Namespace {
    private(set) var names: [Symbol: IntermediateValue]
    let wrappedNamespace: Namespace?

    init(
        names: [Symbol: IntermediateValue],
        wrappedNamespace: Namespace?
    ) {
        self.names = names
        self.wrappedNamespace = wrappedNamespace
    }

    func wrap(names: [Symbol: IntermediateValue]) -> Namespace {
        Namespace(names: names, wrappedNamespace: self)
    }

    subscript(key: Symbol) -> IntermediateValue {
        get throws {
            if let value = self.names[key] {
                return value
            }
            if let wrappedNamespace = wrappedNamespace {
                return try wrappedNamespace[key]
            }
            throw EvaluatorError.missingValue(key)
        }
    }

    func overrideName(_ symbol: Symbol, value: IntermediateValue) {
        self.names[symbol] = value
    }

    static let empty = Namespace(names: [:], wrappedNamespace: nil)
}

extension Namespace: CustomDebugStringConvertible {
    var debugDescription: String {
        let keys = self.names.keys.map(\.name).joined(separator: ", ")
        let wrapped = self.wrappedNamespace.map(\.debugDescription) ?? "(none)"
        return "namespace: \(keys), wrapped: \(wrapped)"
    }
}

func evaluateToOutput(expression: Expression, in context: Context) throws -> SXPJOutputValue {
    var mutableContext = context
    return try evaluateToOutput(expression: expression, mutating: &mutableContext)
}

func evaluateToOutput(expression: Expression, mutating context: inout Context) throws -> SXPJOutputValue {
    try evaluate(expression: expression, in: &context).requireValue
}

func evaluate(expression: Expression, in context: inout Context) throws -> IntermediateValue {
    switch expression {
    case let .value(val):
        return try evaluateValue(value: val, in: &context)
    case let .symbol(symbol):
        return try evaluateSymbol(symbol: symbol, in: &context)
    case let .call(call):
        return try evaluateCall(call: call, in: &context)
    }
}

func evaluateValue(value: ExpressionValue, in context: inout Context) throws -> IntermediateValue {
    switch value {
    case let .string(string):
        return .string(string)
    case let .number(string):
        if let int = Int(string) {
            return .integer(int)
        } else if let double = Double(string) {
            return .double(double)
        } else {
            throw EvaluatorError.badExpressionType(value)
        }
    case let .array(array):
        return try .array(array.map { try evaluate(expression: $0, in: &context) })
    case let .object(array):
        return try .object(array.map { IntermediateObjectMember(name: $0.name, value: try evaluate(expression: $0.value, in: &context)) })
    case let .boolean(bool):
        return .boolean(bool)
    case .null:
        return .null
    case let .expression(expression):
        return try evaluate(expression: expression, in: &context)
    }
}

func evaluateSymbol(symbol: Symbol, in context: inout Context) throws -> IntermediateValue {
    try context.value(for: symbol)
}

func evaluateCall(call: Call, in context: inout Context) throws -> IntermediateValue {
    let target = try evaluate(expression: call.target, in: &context)
    guard case let .callable(callable) = target else {
        throw EvaluatorError.badCallTarget(target)
    }
    return try callable.call(call.params, context: &context)
}

enum EvaluatorError: Error {
    case badCallTarget(IntermediateValue)
    case badExpressionType(ExpressionValue)
    case badFunctionParameters([IntermediateValue], String)
    case badParameterList([Expression], String)
    case divisionByZero(Int)
    case missingValue(Symbol)
    case uncalledFunction
    case unrecognizedNativeType(Any?)
}
