private func addf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    let numbers = try values.map { v -> Double in
        switch v {
        case let .number(n):
            return n
        default:
            throw EvaluatorError.badParameterList(params, "Add requires numbers")
        }
    }
    return .number(numbers.reduce(0, +))
}

extension Function {
    static let addFunction = Function(f: addf(_:_:))
}