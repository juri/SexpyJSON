enum IntermediateValue {
    case callable(Callable)
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