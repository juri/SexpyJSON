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

struct Function {
    let f: ([Expression], inout Context) throws -> IntermediateValue

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        try self.f(params, &context)
    }
}

enum IntermediateValue {
    case function(Function)
    case string(String)
    case integer(Int)
    case double(Double)
    case array([IntermediateValue])
    case object([IntermediateObjectMember])
    case boolean(Bool)
    case null

    var requireValue: SXPJOutputValue {
        get throws {
            switch self {
            case .function:
                throw EvaluatorError.uncalledFunction
            case let .string(s):
                return .string(s)
            case let .integer(i):
                return .number(Double(i))
            case let .double(n):
                return .number(n)
            case let .array(a):
                return try .array(a.map { try $0.requireValue })
            case let .object(a):
                return try .object(a.map { SXPJOutputObjectMember(name: $0.name, value: try $0.value.requireValue) })
            case let .boolean(b):
                return .boolean(b)
            case .null:
                return .null
            }
        }
    }
}

extension IntermediateValue {
    var array: [IntermediateValue]? {
        guard case let .array(a) = self else { return nil }
        return a
    }

    var boolean: Bool? {
        guard case let .boolean(b) = self else { return nil }
        return b
    }

    var double: Double? {
        guard case let .double(d) = self else { return nil }
        return d
    }

    var string: String? {
        guard case let .string(s) = self else { return nil }
        return s
    }
}

struct IntermediateObjectMember {
    var name: String
    var value: IntermediateValue
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
    guard case let .function(fun) = target else {
        throw EvaluatorError.badCallTarget(target)
    }
    return try fun.call(call.params, context: &context)
}

enum EvaluatorError: Error {
    case badCallTarget(IntermediateValue)
    case badExpressionType(ExpressionValue)
    case badParameterList([Expression], String)
    case divisionByZero(Int)
    case missingValue(Symbol)
    case uncalledFunction
}

enum NumberList {
    case integers([Int])
    case doubles([Double])
}

extension IntermediateValue {
    static func numbers(from values: [IntermediateValue]) -> NumberList? {
        var integers = [Int]()
        var doubles = [Double]()
        integers.reserveCapacity(values.count)
        doubles.reserveCapacity(values.count)
        var allIntegers = true
        for value in values {
            switch value {
            case let .integer(i) where allIntegers:
                integers.append(i)
                doubles.append(Double(i))
            case let .integer(i):
                doubles.append(Double(i))
            case let .double(n):
                doubles.append(n)
                allIntegers = false
            default:
                return nil
            }
        }

        return allIntegers ? .integers(integers) : .doubles(doubles)
    }
}
