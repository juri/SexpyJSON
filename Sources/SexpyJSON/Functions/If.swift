/* fundoc name
 if
 */

/* fundoc example
 (define f (fn [a] (if (not (eq a 0))
                        (/ 1 a)
                        0)))
 */

/* fundoc expect
 null
 */

/* fundoc example
 (f 10.0)
 */

/* fundoc expect
 0.1
 */

/* fundoc text
 The `if` form evaluates takes three parameters: an expression evaluating to a boolean, a "then" expression
 and an "else" expression.
 */

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

extension Callable {
    static let ifFunction = Callable.specialOperator(SpecialOperator(f: iff))
}
