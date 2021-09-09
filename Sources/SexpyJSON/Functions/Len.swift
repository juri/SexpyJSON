private func lenf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard params.count == 1 else {
        throw EvaluatorError.badParameterList(params, "len requires one argument")
    }
    switch try evaluate(expression: params[0], in: &context) {
    case let .string(s): return .integer(s.count)
    case let .array(a): return .integer(a.count)
    default:
        throw EvaluatorError.badParameterList(params, "len requires string or array argument")
    }
}

extension Function {
    static let lenFunction = Function(f: lenf(_:_:))
}
