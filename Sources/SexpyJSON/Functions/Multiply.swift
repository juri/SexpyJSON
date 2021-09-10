private func multiplyf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badParameterList(params, "Multiply requires numbers")
    }
    switch numbers {
    case let .integers(array):
        return .integer(array.reduce(1, *))
    case let .doubles(array):
        return .double(array.reduce(1, *))
    }
}

extension Callable {
    static let multiplyFunction = Callable.specialOperator(SpecialOperator(f: multiplyf(_:_:)))
}
