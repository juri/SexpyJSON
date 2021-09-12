// (fn [a1, a2, …, aN] e1 e2 … eN)
// (fn (a1 a2 … aN) e1 e2 … eN)
private func fnf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard let argNames = params.first else {
        throw EvaluatorError.badParameterList(params, "No args list list found for fn")
    }
    let functionArguments: [String]

    switch argNames {
    case let .call(call):
        functionArguments = try call.allExpressions.map(makeNameExtractor(params: params))

    case let .value(.array(elems)):
        functionArguments = try elems.map(makeNameExtractor(params: params))

    case .value(.null):
        functionArguments = []

    default:
        throw EvaluatorError.badParameterList(params, "Bad fn args")
    }

    guard functionArguments.count == Set(functionArguments).count else {
        throw EvaluatorError.badParameterList(params, "fn parameter list names must be unique")
    }

    let fnExpressions = params.dropFirst()
    let originalContext = context
    return .callable(.functionVarargs(.init(noContext: { args in
        guard args.count == functionArguments.count else {
            throw EvaluatorError.badFunctionParameters(args, "Function requires \(args.count) parameters")
        }

        let namespacePairs = zip(functionArguments, args).map { name, value in
            (Symbol(name: name), value)
        }
        let nsDict = Dictionary(namespacePairs, uniquingKeysWith: { $1 })
        var evalContext = originalContext.wrap(names: nsDict)
        var returnValue: IntermediateValue = .null
        for expr in fnExpressions {
            returnValue = try evaluate(expression: expr, in: &evalContext)
        }
        return returnValue
    })))
}

private func makeNameExtractor(params: [Expression]) -> (Expression) throws -> String {
    { expression in
        switch expression {
        case let .symbol(symbol): return symbol.name
        default:
            throw EvaluatorError.badParameterList(params, "Bad fn args")
        }
    }
}

extension Callable {
    static let fnFunction = Callable.specialOperator(SpecialOperator(f: fnf(_:_:)))
}
