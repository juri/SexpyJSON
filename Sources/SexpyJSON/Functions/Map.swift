private func mapf(param1: IntermediateValue, param2: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .callable(callable) = param1 else {
        throw EvaluatorError.badFunctionParameters([param1, param2], "First parameter to map must be callable")
    }

    switch param2 {
    case let .string(s):
        do {
            return try .string(mapString(callable: callable, over: s, context: &context))
        } catch is BadReturnValue {
            throw EvaluatorError.badFunctionParameters([param1, param2], "Function mapping over strings must return one-character strings")
        }
    case let .array(a):
        return try .array(mapArray(callable: callable, over: a, context: &context))
    default:
        throw EvaluatorError.badFunctionParameters([param1, param2], "Second parameter to map must be string or array")
    }
}

private func mapString(callable: Callable, over string: String, context: inout Context) throws -> String {
    let res = try string.map { char -> Character in
        let charExpr = Expression.value(.string(String(char)))
        let mapped = try callable.call([charExpr], context: &context)
        guard case let .string(s) = mapped, s.count == 1 else {
            throw BadReturnValue()
        }
        let char = Character(s)
        return char
    }
    return String(res)
}

private func mapArray(callable: Callable, over array: [IntermediateValue], context: inout Context) throws -> [IntermediateValue] {
    try array.map { val -> IntermediateValue in
        try callable.callFunction([val], context: &context)
    }
}

private struct BadReturnValue: Error {}

extension Callable {
    static let mapFunction = Callable.function2WithContext(.init(f: mapf(param1:param2:_:), name: "map"))
}
