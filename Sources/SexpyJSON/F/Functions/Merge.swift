/* fundoc name
 merge
 */

/* fundoc example
 (merge {"a": "b"} {"c": "d"} {"e": "f"})
 */

/* fundoc expect
 {"a": "b", "c": "d", "e": "f"}
 */

/* fundoc text
 The `merge` function merges the fields of two or more objects or dictionaries, returning a dictionary
 with the key-value pairs from all the parameters. Objects later in the parameter list take precendence
 in collisions.
 */

private func mergef(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard values.count >= 2, let value1 = values.first else {
        throw EvaluatorError.badFunctionParameters(values, "Merge requires at least two parameters")
    }
    do {
        var dict1: [String: Any] = try asDict(value1)
        for anotherValue in values.dropFirst() {
            switch anotherValue {
            case let .dict(anotherDict):
                for (key, value) in anotherDict {
                    dict1[key] = value
                }
            case let .object(members):
                for member in members {
                    dict1[member.name] = member.value
                }
            default:
                throw BadParameterType()
            }
        }
        return IntermediateValue.dict(dict1)
    } catch is BadParameterType {
        throw EvaluatorError.badFunctionParameters(values, "Merge requires parameters to be objects")
    }
}

private func asDict(_ value: IntermediateValue) throws -> [String: Any] {
    switch value {
    case let .dict(d):
        return d
    case let .object(members):
        var output = [String: Any]()
        output.reserveCapacity(members.count)
        for member in members {
            output[member.name] = member.value
        }
        return output
    default:
        throw BadParameterType()
    }
}

private struct BadParameterType: Error {}

extension Callable {
    static let mergeFunction = Callable.functionVarargs(FunctionVarargs(noContext: mergef(_:)))
}
