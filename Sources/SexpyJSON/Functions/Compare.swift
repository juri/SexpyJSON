private func makeComp(
    intTest: @escaping (Int, Int) -> Bool,
    doubleTest: @escaping (Double, Double) -> Bool
) -> ([Expression], inout Context) throws -> IntermediateValue {
    { params, context in
        guard params.count >= 2 else {
            throw EvaluatorError.badParameterList(params, "comparison requires at least two parameters")
        }
        var value1 = try evaluate(expression: params[0], in: &context)
        for expr2 in params.dropFirst() {
            let value2 = try evaluate(expression: expr2, in: &context)
            switch (value1, value2) {
            case let (.integer(i1), .integer(i2)):
                guard intTest(i1, i2) else { return .boolean(false) }
            case let (.double(d1), .double(d2)):
                guard doubleTest(d1, d2) else { return .boolean(false) }
            case let (.integer(i1), .double(d2)):
                guard doubleTest(Double(i1), d2) else { return .boolean(false) }
            case let (.double(d1), .integer(i2)):
                guard doubleTest(d1, Double(i2)) else { return .boolean(false) }
            default:
                throw EvaluatorError.badParameterList(params, "Only numeric types can be compared")
            }
            value1 = value2
        }
        return .boolean(true)
    }
}

extension Callable {
    static let gtFunction = Callable.specialOperator(SpecialOperator(f: makeComp(intTest: >, doubleTest: >)))
    static let gteFunction = Callable.specialOperator(SpecialOperator(f: makeComp(intTest: >=, doubleTest: >=)))
    static let ltFunction = Callable.specialOperator(SpecialOperator(f: makeComp(intTest: <, doubleTest: <)))
    static let lteFunction = Callable.specialOperator(SpecialOperator(f: makeComp(intTest: <=, doubleTest: <=)))
}
