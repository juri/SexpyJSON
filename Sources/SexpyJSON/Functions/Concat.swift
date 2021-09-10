private func concatf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard params.count > 1 else {
        throw EvaluatorError.badParameterList(params, "concat requires at least two arguments")
    }
    let values = try params.map { try evaluate(expression: $0, in: &context) }
    guard let output = concatStrings(values) ?? concatArrays(values) else {
        throw EvaluatorError.badParameterList(params, "Couldn't concat parameters")
    }

    return output
}

private func concatStrings(_ values: [IntermediateValue]) -> IntermediateValue? {
    guard let first = values.first?.string else { return nil }
    var strings: [String] = [first]
    strings.reserveCapacity(values.count)
    for value in values.dropFirst() {
        guard let str = value.string else { return nil }
        strings.append(str)
    }
    return .string(strings.joined(separator: ""))
}

private func concatArrays(_ values: [IntermediateValue]) -> IntermediateValue? {
    guard let first = values.first?.array else { return nil }
    var arrays: [[IntermediateValue]] = [first]
    arrays.reserveCapacity(values.count)
    for value in values.dropFirst() {
        guard let array = value.array else { return nil }
        arrays.append(array)
    }
    return .array(Array(arrays.joined(separator: [])))
}

extension Callable {
    static let concatFunction = Callable.specialOperator(SpecialOperator(f: concatf(_:_:)))
}
