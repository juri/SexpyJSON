private func subtractf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badParameterList(params, "Subtract requires numbers")
    }
    switch numbers {
    case .integers(let array):
        guard let first = array.first else { return .integer(0) }
        return .integer(array.dropFirst().reduce(first, -))
    case .doubles(let array):
        guard let first = array.first else { return .number(0) }
        return .number(array.dropFirst().reduce(first, -))
    }
}

extension Function {
    static let subtractFunction = Function(f: subtractf(_:_:))
}
