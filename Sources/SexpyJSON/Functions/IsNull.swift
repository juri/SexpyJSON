private func isNullf(_ value: IntermediateValue) -> IntermediateValue {
    if case .null = value { return .boolean(true) }
    return .boolean(false)
}

extension Callable {
    static let isNullFunction = Callable.function1(Function1(f: isNullf(_:), name: "is-null"))
}
