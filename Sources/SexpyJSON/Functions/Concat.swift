private func concatf(_ values: [IntermediateValue]) throws -> IntermediateValue {
    guard values.count > 1 else {
        throw EvaluatorError.badFunctionParameters(values, "concat requires at least two arguments")
    }
    guard let output = try concatStrings(values) ?? concatArrays(values) else {
        throw EvaluatorError.badFunctionParameters(values, "Couldn't concat parameters")
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

private func concatArrays(_ values: [IntermediateValue]) throws -> IntermediateValue? {
    guard let first = try values.first?.anyArray else { return nil }
    var arrays: [[IntermediateValue]] = [first]
    arrays.reserveCapacity(values.count)
    for value in values.dropFirst() {
        guard let array = try value.anyArray else { return nil }
        arrays.append(array)
    }
    return .array(Array(arrays.joined(separator: [])))
}

extension Callable {
    static let concatFunction = Callable.functionVarargs(FunctionVarargs(f: concatf(_:)))
}
