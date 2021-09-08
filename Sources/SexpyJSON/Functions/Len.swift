private func lenf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard params.count == 1 else {
        throw EvaluatorError.badParameterList(params, "len requires one argument")
    }
    switch params[0] {
    case let .value(.string(s)): return .integer(s.count)
    case let .value(.array(a)): return .integer(a.count)
    default:
        throw EvaluatorError.badParameterList(params, "len requires string or array argument")
    }
}

extension Function {
    static let lenFunction = Function(f: lenf(_:_:))
}
