private func addf(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badFunctionParameters(values, "Add requires numbers")
    }
    switch numbers {
    case let .integers(array):
        return .integer(array.reduce(0, +))
    case let .doubles(array):
        return .double(array.reduce(0, +))
    }
}

extension Callable {
    static let addFunction = Callable.functionVarargs(FunctionVarargs(f: addf))
}
