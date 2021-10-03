/* fundoc name
 ??
 */

/* fundoc section
 specialforms
 */

/* fundoc example
 (?? null "fallback")
 */

/* fundoc expect
 "fallback"
 */

/* fundoc example
 (??)
 */

/* fundoc expect
 null
 */

/* fundoc example
 (?? 1)
 */

/* fundoc expect
 1
 */

/* fundoc example
 (?? null)
 */

/* fundoc expect
 null
 */

/*
 The `??` operator returns the first of its parameters that is not null. It evaluates the parameters on demand.
 */

private func nonNullOr(_ expressions: [Expression], _ context: inout Context) throws -> IntermediateValue {
    var result = IntermediateValue.null
    for expr in expressions {
        result = try evaluate(expression: expr, in: &context)
        if !result.isNull {
            return result
        }
    }
    return result
}

extension Callable {
    static let nonNullOrFunction = Callable.specialOperator(.init(f: nonNullOr(_:_:)))
}
