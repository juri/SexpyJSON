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
