/* fundoc name
 fn
 */

/* fundoc section
 specialforms
 */

/* fundoc example
 ((fn [a] (* a a)) 3)
 */

/* fundoc expect
 9.0
 */

/* fundoc example
 (((fn [a] (fn [b] (* a b))) 3) 4)
 */

/* fundoc expect
 12.0
 */

/* fundoc text
 The `fn` form defines a function. Its first parameter is an array of parameters, and it evaluates the rest
 of the expressions one by one, returning the value from the last one. The functions defined with `fn`
 capture their lexical scope: you can refer to values in the containing source location when you return
 values from functions or pass functions as parameters.
 */

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

/* fundoc name
 dynfn
 */

/* fundoc section
 specialforms
 */

/* fundoc example
 (let (my-dynamic-function (dynfn [] (* 10 dynamic-value)))
    (let (dynamic-value 5)
        (my-dynamic-function)))
 */

/* fundoc expect
 50.0
 */

/* fundoc text
 The `dynfn` form defines a dynamically scoped function. Unlike <<_fn>> which operates in its lexical scope —
 seeing the names available where it's defined in the source file — a function defined with `dynfn` operates
 in a dynamic scope, seeing the values in its caller's namespace.
 */

private func dynfnf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
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
    return .callable(.functionVarargs(.init(f: { args, callContext in
        guard args.count == functionArguments.count else {
            throw EvaluatorError.badFunctionParameters(args, "Function requires \(args.count) parameters")
        }

        let namespacePairs = zip(functionArguments, args).map { name, value in
            (Symbol(name: name), value)
        }
        let nsDict = Dictionary(namespacePairs, uniquingKeysWith: { $1 })
        var evalContext = callContext.wrap(names: nsDict)
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
    static let dynFnFunction = Callable.specialOperator(SpecialOperator(f: dynfnf(_:_:)))
    static let fnFunction = Callable.specialOperator(SpecialOperator(f: fnf(_:_:)))
}
