private func makeComp(
    intTest: @escaping (Int, Int) -> Bool,
    doubleTest: @escaping (Double, Double) -> Bool
) -> ([IntermediateValue]) throws -> IntermediateValue {
    { values in
        guard values.count >= 2 else {
            throw EvaluatorError.badFunctionParameters(values, "comparison requires at least two parameters")
        }
        var value1 = values[0]
        for value2 in values.dropFirst() {
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
                throw EvaluatorError.badFunctionParameters(values, "Only numeric types can be compared")
            }
            value1 = value2
        }
        return .boolean(true)
    }
}

extension Callable {
    static let gtFunction = Callable.functionVarargs(FunctionVarargs(noContext: makeComp(intTest: >, doubleTest: >)))
    static let gteFunction = Callable.functionVarargs(FunctionVarargs(noContext: makeComp(intTest: >=, doubleTest: >=)))
    static let ltFunction = Callable.functionVarargs(FunctionVarargs(noContext: makeComp(intTest: <, doubleTest: <)))
    static let lteFunction = Callable.functionVarargs(FunctionVarargs(noContext: makeComp(intTest: <=, doubleTest: <=)))
}
