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
    static let subtractFunction = Callable.functionVarargs(FunctionVarargs(f: subtractf(_:)))
}
