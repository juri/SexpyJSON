/* fundoc name
 filter
 */

/* fundoc example
 (filter (fn (a) (> a 2)) [0, 1, 2, 3, 2, 4, 3, 1])
 */

/* fundoc expect
 [3, 4, 3]
 */

/* fundoc text
 The `filter` function filters an array with a predicate function. The return value is an array
 with the elements for which the function returns true.
 */

private func filterf(param1: IntermediateValue, param2: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .callable(callable) = param1 else {
        throw EvaluatorError.badFunctionParameters([param1, param2], "First parameter to fliter must be callable")
    }

    do {
        switch param2 {
        case let .array(a):
            return try filterArray(a, callable: callable, context: &context)
        case let .nativeArray(a):
            let convertedArray = try IntermediateValue.tryInitUnwrappedArray(nativeValue: a)
            return try filterArray(convertedArray, callable: callable, context: &context)
        default:
            throw EvaluatorError.badFunctionParameters([param1, param2], "Second parameter to filter must be array")
        }
    } catch is BadPredicateReturnType {
        throw EvaluatorError.badFunctionParameters([param1, param2], "Filter function must return booleans")
    }
}

private func filterArray(
    _ array: [IntermediateValue],
    callable: Callable,
    context: inout Context
) throws -> IntermediateValue {
    let filtered = try array.filter { elem in
        guard let bool = try callable.callFunction([elem], context: &context).boolean else {
            throw BadPredicateReturnType()
        }
        return bool
    }
    return .array(filtered)
}

private struct BadPredicateReturnType: Error {}

extension Callable {
    static let filterFunction = Callable.function2(.init(f: filterf(param1:param2:_:), name: "filter"))
}
