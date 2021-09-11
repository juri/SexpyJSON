private func filterf(param1: IntermediateValue, param2: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .callable(callable) = param1 else {
        throw EvaluatorError.badFunctionParameters([param1, param2], "First parameter to fliter must be callable")
    }

    guard case let .array(a) = param2 else {
        throw EvaluatorError.badFunctionParameters([param1, param2], "Second parameter to filter must be array")
    }

    let filtered = try a.filter { elem in
        guard let bool = try callable.callFunction([elem], context: &context).boolean else {
            throw EvaluatorError.badFunctionParameters([param1, param2], "Filter function must return booleans")
        }
        return bool
    }
    return .array(filtered)
}

extension Callable {
    static let filterFunction = Callable.function2WithContext(.init(f: filterf(param1:param2:_:), name: "filter"))
}
