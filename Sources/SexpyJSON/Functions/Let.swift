// (let [binding1 value1 binding2 value2 binding3 binding1] expr1 expr2 … exprN)
private func letf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard let bindings = params.first else {
        throw EvaluatorError.badParameterList(params, "No bindings list found for let")
    }
    let bindingName = makeNameExtractor(params: params)
    var context = context
    switch bindings {
    case let .value(.array(elems)):
        guard elems.count.isMultiple(of: 2) else {
            throw EvaluatorError.badParameterList(params, "Bad number of elements in let bindings: must be even")
        }
        var nestedContext = context
        for symbolIndex in stride(from: 0, to: elems.endIndex, by: 2) {
            let name = try bindingName(elems[symbolIndex])
            let value = try evaluate(expression: elems[symbolIndex + 1], in: &nestedContext)
            nestedContext = nestedContext.wrap(names: [Symbol(name): value])
        }
        context = nestedContext

    case .value(.null):
        break
    default:
        throw EvaluatorError.badParameterList(params, "Bad let bindings")
    }

    var returnValue: IntermediateValue = .null

    for expr in params.dropFirst() {
        returnValue = try evaluate(expression: expr, in: &context)
    }
    return returnValue
}

private func makeNameExtractor(params: [Expression]) -> (Expression) throws -> String {
    { expression in
        switch expression {
        case let .symbol(s): return s.name
        default:
            throw EvaluatorError.badParameterList(params, "Bad let bindings")
        }
    }
}

extension Function {
    static let letFunction = Function(f: letf(_:_:))
}
