/* fundoc name
 not
 */

/* fundoc example
 (not true)
 */

/* fundoc expect
 false
 */

/* fundoc example
 (not false)
 */

/* fundoc expect
 true
 */

/* fundoc text
 The `not` function is the boolean not operation, returning the inverse of the boolean it received as
 a parameter.
 */

func notf(_ param: IntermediateValue) throws -> IntermediateValue {
    guard case let .boolean(bool) = param else {
        throw EvaluatorError.badFunctionParameters([param], "Not takes one boolean parameter")
    }
    return .boolean(!bool)
}

extension Callable {
    static let notFunction = Callable.function1(.init(f: notf(_:), name: "not"))
}
