/* fundoc name
 as-dict
 */

/* fundoc example
 (as-dict { "hello": "world" })
 */

/* fundoc text
 The `as-dict` function converts an object to a dictionary.
 */

private func asDictf(_ value: IntermediateValue) throws -> IntermediateValue {
    switch value {
    case .dict: return value
    case let .object(members):
        var output = [String: Any]()
        output.reserveCapacity(members.count)
        for member in members {
            output[member.name] = member.value
        }
        return .dict(output)
    default:
        throw EvaluatorError.badFunctionParameters([value], "as-dict requires one parameter which must be a dict or an object")
    }
}

extension Callable {
    static let asDictFunction = Callable.function1(.init(f: asDictf(_:), name: "as-dict"))
}
