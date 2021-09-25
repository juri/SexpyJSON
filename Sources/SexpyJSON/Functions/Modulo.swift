/* fundoc name
 %
 */

/* fundoc example
 (% 20 12 3)
 */

/* fundoc expect
 2.0
 */

/* fundoc text
 `%` is the modulo (remainder) operator. It operates on integers or doubles. It converts integers to doubles
 if it receives both as arguments.
 */

private func modf(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badFunctionParameters(values, "The % function requires numbers")
    }
    switch numbers {
    case let .integers(array):
        guard let first = array.first else { return .integer(0) }
        let result = try array.dropFirst().reduce(first) { total, num in
            guard num != 0 else { throw EvaluatorError.divisionByZero(total) }
            return total % num
        }
        return .integer(result)
    case let .doubles(array):
        guard let first = array.first else { return .double(0) }
        return .double(array.dropFirst().reduce(first) { $0.truncatingRemainder(dividingBy: $1) })
    }
}

extension Callable {
    static let moduloFunction = Callable.functionVarargs(FunctionVarargs(noContext: modf(_:)))
}
