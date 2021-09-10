private func subtractf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badParameterList(params, "Subtract requires numbers")
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
    static let subtractFunction = Callable.specialOperator(SpecialOperator(f: subtractf(_:_:)))
}
