struct Context {
    var namespace: Namespace

    func value(for symbol: Symbol) throws -> IntermediateValue {
        return try namespace[symbol]
    }
}

final class Namespace {
    let names: [Symbol: IntermediateValue]
    let wrappedNamespace: Namespace?

    init(
        names: [Symbol: IntermediateValue],
        wrappedNamespace: Namespace?
    ) {
        self.names = names
        self.wrappedNamespace = wrappedNamespace
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
}

struct Function {
    let f: ([Expression], inout Context) throws -> IntermediateValue

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        try self.f(params, &context)
    }
}

enum IntermediateValue {
    case function(Function)
    case string(String)
    case number(Double)
    case array([IntermediateValue])
    case object([IntermediateObjectMember])
    case boolean(Bool)
    case null

    var requireValue: OutputValue {
        get throws {
            switch self {
            case .function(_):
                throw EvaluatorError.uncalledFunction
            case let .string(s):
                return .string(s)
            case let .number(n):
                return .number(n)
            case let .array(a):
                return try .array(a.map { try $0.requireValue })
            case let .object(a):
                return try .object(a.map { OutputObjectMember(name: $0.name, value: try $0.value.requireValue ) } )
            case let .boolean(b):
                return .boolean(b)
            case .null:
                return .null
            }
        }
    }
}

struct IntermediateObjectMember {
    var name: String
    var value: IntermediateValue
}

enum OutputValue: Equatable {
    case string(String)
    case number(Double)
    case array([OutputValue])
    case object([OutputObjectMember])
    case boolean(Bool)
    case null
}

struct OutputObjectMember: Equatable {
    var name: String
    var value: OutputValue
}

func evaluateToOutput(expression: Expression, in context: Context) throws -> OutputValue {
    var mutableContext = context
    return try evaluate(expression: expression, in: &mutableContext).requireValue
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
        guard let num = numberFormatter.number(from: string)?.doubleValue else {
            throw EvaluatorError.badExpressionType(value)
        }
        return .number(num)
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
    guard case let .function(fun) = target else {
        throw EvaluatorError.badCallTarget(target)
    }
    return try fun.call(call.params, context: &context)
}

enum EvaluatorError: Error {
    case badCallTarget(IntermediateValue)
    case badExpressionType(ExpressionValue)
    case badParameterList([Expression], String)
    case missingValue(Symbol)
    case uncalledFunction
}
