// (define fname (fn [a1 a2 a3] (fname a1 a2 a3)))
private func definef(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard params.count == 2 else {
        throw EvaluatorError.badParameterList(params, "Exactly two parameters required for define")
    }
    guard let name = params.first?.symbol?.name else {
        throw EvaluatorError.badParameterList(params, "No name found for define: first parameter must be name")
    }
    guard let expr = params.dropFirst().first else {
        assertionFailure("The first guard earlier should have covered this case")
        throw EvaluatorError.badParameterList(params, "No value found for define")
    }

    let exprResult = try evaluate(expression: expr, in: &context)
    context.namespace = context.namespace.wrap(names: [.name(name): exprResult])

    return .null
}

extension Function {
    static let defineFunction = Function(f: definef(_:_:))
}
