// (if cond then-expr else-expr)
private func iff(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard params.count == 3 else {
        throw EvaluatorError.badParameterList(params, "if requires three parameters")
    }

    let condResult = try evaluate(expression: params[0], in: &context)
    guard let condBool = condResult.boolean else {
        throw EvaluatorError.badParameterList(params, "First parameter of if must return a boolean")
    }

    return try evaluate(expression: params[condBool ? 1 : 2], in: &context)
}

extension Function {
    static let ifFunction = Function(f: iff)
}
