/* fundoc name
 as-object
 */

/* fundoc example
 (as-object (merge { "k1": "v1" } { "k2": "v2" }))
 */

/* fundoc text
 The `as-object` function converts a dictionary to an object.
 */

private func asObjectf(_ value: IntermediateValue) throws -> IntermediateValue {
    switch value {
    case .object: return value
    case let .dict(d): return try IntermediateValue.tryInitObject(nativeValue: d)
    default:
        throw EvaluatorError.badFunctionParameters([value], "as-object requires one parameter which must be a dict or an object")
    }
}

extension Callable {
    static let asObjectFunction = Callable.function1(.init(f: asObjectf(_:), name: "as-object"))
}
