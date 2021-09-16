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
