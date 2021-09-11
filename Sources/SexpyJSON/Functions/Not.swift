func notf(_ param: IntermediateValue) throws -> IntermediateValue {
    guard case let .boolean(bool) = param else {
        throw EvaluatorError.badFunctionParameters([param], "Not takes one boolean parameter")
    }
    return .boolean(!bool)
}

extension Callable {
    static let notFunction = Callable.function1(.init(f: notf(_:), name: "not"))
}
