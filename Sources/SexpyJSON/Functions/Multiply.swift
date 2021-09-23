/* fundoc name
 *
 */

/* fundoc example
 (* 12 -13 14)
 */

/* fundoc expect
 -2184.0
 */

/* fundoc text
 `*` is the multiplication operator. It operates on integers or doubles. It converts integers to doubles
 if it receives both as arguments.
 */

private func multiplyf(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badFunctionParameters(values, "Multiply requires numbers")
    }
    switch numbers {
    case let .integers(array):
        return .integer(array.reduce(1, *))
    case let .doubles(array):
        return .double(array.reduce(1, *))
    }
}

extension Callable {
    static let multiplyFunction = Callable.functionVarargs(FunctionVarargs(noContext: multiplyf(_:)))
}
