private func lenf(_ param: IntermediateValue) throws -> IntermediateValue {
    switch param {
    case let .string(s): return .integer(s.count)
    case let .array(a): return .integer(a.count)
    default:
        throw EvaluatorError.badFunctionParameters([param], "len requires string or array argument")
    }
}

extension Callable {
    static let lenFunction = Callable.simpleFunction1(SimpleFunction1(f: lenf, name: "len"))
}
