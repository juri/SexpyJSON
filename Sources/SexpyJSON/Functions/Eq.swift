private func eqf(_ params: [Expression], _ context: inout Context) throws -> IntermediateValue {
    guard params.count >= 2 else {
        throw EvaluatorError.badParameterList(params, "eq requires at least two parameters")
    }
    let value1 = try evaluate(expression: params[0], in: &context)
    for expr2 in params.dropFirst() {
        let value2 = try evaluate(expression: expr2, in: &context)
        guard try eq(value1: value1, value2: value2, context) else { return .boolean(false) }
    }
    return .boolean(true)
}

private func eq(array1: [IntermediateValue], array2: [IntermediateValue], _ context: Context) throws -> Bool {
    guard array1.count == array2.count else { return false }
    for index in array1.indices {
        guard try eq(value1: array1[index], value2: array2[index], context) else { return false }
    }
    return true
}

private func eq(
    object1: [IntermediateObjectMember],
    object2: [IntermediateObjectMember],
    _ context: Context
) throws -> Bool {
    guard object1.count == object2.count else { return false }
    let object1Sorted = object1.sorted(by: { $0.name < $1.name })
    let object2Sorted = object2.sorted(by: { $0.name < $1.name })
    for index in object1Sorted.indices {
        let pair1 = object1Sorted[index]
        let pair2 = object2Sorted[index]
        guard pair1.name == pair2.name, try eq(value1: pair1.value, value2: pair2.value, context) else {
            return false
        }
    }
    return true
}

private func eq(value1: IntermediateValue, value2: IntermediateValue, _ context: Context) throws -> Bool {
    switch (value1, value2) {
    case let (.string(s1), .string(s2)):
        return s1 == s2
    case let (.double(n1), .double(n2)):
        return n1 == n2
    case let (.integer(n1), .integer(n2)):
        return n1 == n2
    case let (.boolean(b1), .boolean(b2)):
        return b1 == b2
    case let (.array(a1), .array(a2)):
        return try eq(array1: a1, array2: a2, context)
    case let (.object(o1), .object(o2)):
        return try eq(object1: o1, object2: o2, context)
    case (.null, .null):
        return true
    default:
        return false
    }
}

extension Function {
    static let eqFunction = Function(f: eqf(_:_:))
}
