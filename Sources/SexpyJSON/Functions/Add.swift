private func addf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badParameterList(params, "Add requires numbers")
    }
    switch numbers {
    case .integers(let array):
        return .integer(array.reduce(0, +))
    case .doubles(let array):
        return .number(array.reduce(0, +))
    }
}

extension Function {
    static let addFunction = Function(f: addf(_:_:))
}
