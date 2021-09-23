/* fundoc name
 let
 */

/* fundoc example
 (let (a 2
       b (* a 3)
       c (* b a))
    c)
 */

/* fundoc expect
 12.0
 */

/* fundoc text
 The `let` form creates a new namespace with value bindings from the first expression and evaluates the
 rest of the expressions one by one, returning the value from the last one. The first expression consists
 of pairs of values, alternating between variable names and values. Each definition sees the ones created
 before it. The names defined in let are not visible when you leave the let.
 */

// (let (binding1 value1 binding2 value2 binding3 binding1) expr1 expr2 … exprN)
private func letf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard let bindings = params.first else {
        throw EvaluatorError.badParameterList(params, "No bindings list found for let")
    }
    let bindingName = makeNameExtractor(params: params)
    var context = context
    switch bindings {
    case let .call(call):
        let elems = call.allExpressions
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

extension Callable {
    static let letFunction = Callable.specialOperator(SpecialOperator(f: letf(_:_:)))
}
