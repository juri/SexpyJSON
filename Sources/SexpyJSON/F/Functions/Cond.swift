/* fundoc name
 cond
 */

/* fundoc section
 specialforms
 */

/* fundoc example
 (let (a 1)
  (cond (< a 0) "less than zero"
        (< a 2) "less than two"
        true "greater than or equal to two"))
  */

/* fundoc expect
 "less than two"
 */

/* fundoc example
 (let (a 3)
  (cond (< a 0) "less than zero"
        (< a 2) "less than two"
        true "greater than or equal to two"))
  */

/* fundoc expect
 "greater than or equal to two"
 */

/* fundoc example
 (cond false "this is not going to match")
  */

/* fundoc expect
 null
  */

/* fundoc example
 (cond)
  */

/* fundoc expect
 null
  */

/* fundoc text
 The `cond` form allows you to express a conditional with multiple branches. It uses condition-branch pairs,
 returning the value of the first branch that matches the preceding conditional.
 If no branches match, it returns null.

 `cond` requires an even number of arguments.
 */

private func condf(_ expressions: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard expressions.count.isMultiple(of: 2) else {
        throw EvaluatorError.badParameterList(
            expressions, "Must have an even number of arguments for cond"
        )
    }
    for (condition, branch) in expressions.chunk2() {
        if let result = try runBranch(condition: condition, branch: branch, context: &context) {
            return result
        }
    }
    return .null
}

private func runBranch(condition: Expression, branch: Expression, context: inout Context) throws -> IntermediateValue? {
    let result = try evaluate(expression: condition, in: &context)
    guard let shouldRun = result.boolean else {
        throw EvaluatorError.badParameterList(
            [condition, branch], "Bad branch condition type for cond: must be boolean"
        )
    }
    guard shouldRun else { return nil }
    return try evaluate(expression: branch, in: &context)
}

extension Callable {
    static let condFunction = Callable.specialOperator(.init(f: condf(_:_:)))
}
