/* fundoc name
 /
 */

/* fundoc example
 (/ 12.0 -13.0 14.0)
 */

/* fundoc expect
 -0.06593407
 */

/* fundoc example
 (/ 25 2)
 */

/* fundoc expect
 12
 */

/* fundoc text
 `/` is the division operator. It operates on integers or doubles. It converts integers to doubles
 if it receives both as arguments. It performs integer division when operating on integers, discarding
 the fraction part.
 */

private func dividef(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badFunctionParameters(values, "Divide requires numbers")
    }

    switch numbers {
    case let .integers(array):
        guard let first = array.first else { return .integer(0) }
        let result = try array.dropFirst().reduce(first) { total, num in
            guard num != 0 else { throw EvaluatorError.divisionByZero(total) }
            return total / num
        }
        return .integer(result)
    case let .doubles(array):
        guard let first = array.first else { return .double(0) }
        return .double(array.dropFirst().reduce(first, /))
    }
}

extension Callable {
    static let divideFunction = Callable.functionVarargs(FunctionVarargs(noContext: dividef(_:)))
}
