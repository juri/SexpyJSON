/* fundoc name
 apply
 */

/* fundoc example
 (apply concat ["abc", "def", "ghi"])
 */

/* fundoc expect
 "abcdefghi"
  */

/* fundoc example
 (apply (fn [a, b, c] (+ a b c)) [10, 20, 30])
 */

/* fundoc expect
 60
  */

/* fundoc text
 The `apply` function calls a function with parameters from the array. The function can be a built-in one
 or one defined in SexpyJSON.
 */

private func applyf(_ param1: IntermediateValue, _ param2: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard let callable = param1.callable else {
        throw EvaluatorError.badFunctionParameters(
            [param1, param2], "apply requires the first parameter to be callable"
        )
    }

    guard let callableParams = try param2.anyArray else {
        throw EvaluatorError.badFunctionParameters(
            [param1, param2], "apply requires the second parameter to be an array"
        )
    }

    return try callable.callFunction(callableParams, context: &context)
}

extension Callable {
    static let applyFunction = Callable.function2(.init(f: applyf(_:_:_:), name: "apply"))
}
