enum IntermediateValue {
    case callable(Callable)
    case string(String)
    case integer(Int)
    case double(Double)
    case array([IntermediateValue])
    case object([IntermediateObjectMember])
    case boolean(Bool)
    case null
    case nativeArray([Any])
    case dict([String: Any])

    var requireValue: SXPJOutputValue {
        get throws {
            switch self {
            case .callable:
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
            case let .nativeArray(arr):
                return try IntermediateValue.tryInitArray(nativeValue: arr).requireValue
            case let .dict(d):
                return try .object(
                    d.map { k, v in
                        let iv = try v as? IntermediateValue ?? IntermediateValue(nativeValue: v)
                        let ov = try iv.requireValue
                        return SXPJOutputObjectMember(name: k, value: ov)
                    }
                )
            }
        }
    }

    init(nativeValue: Any?) throws {
        switch nativeValue {
        case let iv as IntermediateValue:
            self = iv
        case let int as Int:
            self = .integer(int)
        case let str as String:
            self = .string(str)
        case let double as Double:
            self = .double(double)
        case let bool as Bool:
            self = .boolean(bool)
        case let arr as [Any]:
            self = try IntermediateValue.array(arr.map(IntermediateValue.init(nativeValue:)))
        case let dict as [String: Any]:
            self = .dict(dict)
        case nil:
            self = .null
        default:
            throw EvaluatorError.unrecognizedNativeType(nativeValue)
        }
    }
}

extension IntermediateValue {
    var array: [IntermediateValue]? {
        guard case let .array(a) = self else { return nil }
        return a
    }

    var anyArray: [IntermediateValue]? {
        get throws {
            if let arr = self.array { return arr }
            return try self.nativeArray.flatMap { try IntermediateValue.tryInitArray(nativeValue: $0).array }
        }
    }

    var boolean: Bool? {
        guard case let .boolean(b) = self else { return nil }
        return b
    }

    var callable: Callable? {
        guard case let .callable(c) = self else { return nil }
        return c
    }

    var double: Double? {
        guard case let .double(d) = self else { return nil }
        return d
    }

    var string: String? {
        guard case let .string(s) = self else { return nil }
        return s
    }

    var nativeArray: [Any]? {
        guard case let .nativeArray(a) = self else { return nil }
        return a
    }
}

struct IntermediateObjectMember {
    var name: String
    var value: IntermediateValue
}

enum NumberList {
    case integers([Int])
    case doubles([Double])
}

extension IntermediateValue {
    static func tryInitUnwrappedArray(nativeValue arr: [Any]) throws -> [IntermediateValue] {
        try arr.map(IntermediateValue.tryInit(nativeValue:))
    }

    static func tryInitArray(nativeValue arr: [Any]) throws -> IntermediateValue {
        IntermediateValue.array(try self.tryInitUnwrappedArray(nativeValue: arr))
    }

    static func tryInitObject(nativeValue dict: [String: Any]) throws -> IntermediateValue {
        let members = try dict.map { key, value -> IntermediateObjectMember in
            if let subDict = value as? [String: Any] {
                let convertedValue = try IntermediateValue.tryInitObject(nativeValue: subDict)
                return IntermediateObjectMember(name: key, value: convertedValue)
            }
            return try IntermediateObjectMember(name: key, value: IntermediateValue(nativeValue: value))
        }
        return .object(members)
    }

    static func tryInit(nativeValue: Any?) throws -> IntermediateValue {
        try IntermediateValue(nativeValue: nativeValue)
    }

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
