private func dividef(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let numbers = IntermediateValue.numbers(from: values) else {
        throw EvaluatorError.badParameterList(params, "Divide requires numbers")
    }

    switch numbers {
    case .integers(let array):
        guard let first = array.first else { return .integer(0) }
        let result = try array.dropFirst().reduce(first) { total, num in
            guard num != 0 else { throw EvaluatorError.divisionByZero(total) }
            return total / num
        }
        return .integer(result)
    case .doubles(let array):
        guard let first = array.first else { return .double(0) }
        return .double(array.dropFirst().reduce(first, /))
    }
}

extension Function {
    static let divideFunction = Function(f: dividef(_:_:))
}
