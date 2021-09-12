private func isNilf(_ value: IntermediateValue) -> IntermediateValue {
    if case .null = value { return .boolean(true) }
    return .boolean(false)
}

extension Callable {
    static let isNilFunction = Callable.function1(Function1(f: isNilf(_:), name: "is-nil"))
}
