/* fundoc name
 flatmap
 */

/* fundoc example
 (flatmap (fn (a) [a, a]) [1, 2])
 */

/* fundoc expect
 [1, 1, 2, 2]
 */

/* fundoc text
 The `flatmap` function maps over an array with a function that returns arrays and joins the returned
 arrays.
 */

private func flatmapf(param1: IntermediateValue, param2: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .callable(callable) = param1 else {
        throw EvaluatorError.badFunctionParameters([param1, param2], "First parameter to flatmap must be callable")
    }

    switch param2 {
    case let .string(s):
        do {
            return try .string(flatmapString(callable: callable, over: s, context: &context))
        } catch is BadReturnValue {
            throw EvaluatorError.badFunctionParameters([param1, param2], "Function mapping over strings must return one-character strings")
        }
    case let .array(a):
        return try .array(mapArray(callable: callable, over: a, context: &context))
    case let .nativeArray(a):
        let convertedArray = try IntermediateValue.tryInitUnwrappedArray(nativeValue: a)
        return try .array(mapArray(callable: callable, over: convertedArray, context: &context))
    default:
        throw EvaluatorError.badFunctionParameters([param1, param2], "Second parameter to flatmap must be string or array")
    }
}

private func flatmapString(callable: Callable, over string: String, context: inout Context) throws -> String {
    let res = try string.flatMap { char -> String in
        let charExpr = Expression.value(.string(String(char)))
        let mapped = try callable.call([charExpr], context: &context)
        guard case let .string(s) = mapped else {
            throw BadReturnValue()
        }
        return s
    }
    return String(res)
}

private func mapArray(callable: Callable, over array: [IntermediateValue], context: inout Context) throws -> [IntermediateValue] {
    try array.flatMap { val -> [IntermediateValue] in
        switch try callable.callFunction([val], context: &context) {
        case let .array(arr):
            return arr
        case let .nativeArray(arr):
            let convertedArray = try IntermediateValue.tryInitUnwrappedArray(nativeValue: arr)
            return try mapArray(callable: callable, over: convertedArray, context: &context)
        default:
            throw BadReturnValue()
        }
    }
}

private struct BadReturnValue: Error {}

extension Callable {
    static let flatmapFunction = Callable.function2(.init(f: flatmapf(param1:param2:_:), name: "flatmap"))
}
