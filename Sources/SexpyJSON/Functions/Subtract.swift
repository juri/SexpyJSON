/* fundoc name
 -
 */

/* fundoc example
 (- 12 -13 14)
 */

/* fundoc expect
 11
 */

/* fundoc text
 `-` is the subtraction operator. It operates on integers or doubles. It converts integers to doubles
 if it receives both as arguments.
 */

private func subtractf(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badFunctionParameters(values, "Subtract requires numbers")
    }
    switch numbers {
    case let .integers(array):
        guard let first = array.first else { return .integer(0) }
        return .integer(array.dropFirst().reduce(first, -))
    case let .doubles(array):
        guard let first = array.first else { return .double(0) }
        return .double(array.dropFirst().reduce(first, -))
    }
}

extension Callable {
    static let subtractFunction = Callable.functionVarargs(FunctionVarargs(noContext: subtractf(_:)))
}
