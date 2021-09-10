// (define fname (fn [a1, a2, a3] (fname a1 a2 a3)))
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

    // Because define modifies the current namespace AND
    // also makes the name available for inside the defined
    // value, this is a bit complicated. We must introduce
    // the name in the context we use when we evaluate the
    // expression, and then replace the value after we get
    // it from the evaluator.
    var newContext = context.wrap(names: [Symbol(name): .null])
    let exprResult = try evaluate(expression: expr, in: &newContext)
    // Insert the new name into the namespace potentially captured by
    // the evaluation.
    newContext.namespace.overrideName(Symbol(name), value: exprResult)
    // And also insert it into the we got as a parameter.
    context.namespace = context.namespace.wrap(names: [Symbol(name): exprResult])

    return .null
}

extension Callable {
    static let defineFunction = Callable.specialOperator(SpecialOperator(f: definef(_:_:)))
}
