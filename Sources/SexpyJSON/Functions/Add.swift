private func addf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badParameterList(params, "Add requires numbers")
    }
    switch numbers {
    case let .integers(array):
        return .integer(array.reduce(0, +))
    case let .doubles(array):
        return .double(array.reduce(0, +))
    }
}

extension Callable {
    static let addFunction = Callable.specialOperator(SpecialOperator(f: addf(_:_:)))
}
