private func dividef(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    let numbers = try values.map { v -> Double in
        switch v {
        case let .number(n):
            return n
        default:
            throw EvaluatorError.badParameterList(params, "Divide requires numbers")
        }
    }
    guard let first = numbers.first else { return .number(0) }
    return .number(numbers.dropFirst().reduce(first, /))
}

extension Function {
    static let divideFunction = Function(f: dividef(_:_:))
}
