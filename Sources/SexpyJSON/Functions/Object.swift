private func objectf(_ params: [IntermediateValue]) throws -> IntermediateValue {
    try build(
        params: params,
        make: { count -> [IntermediateObjectMember] in
            var members = [IntermediateObjectMember]()
            members.reserveCapacity(count)
            return members
        },
        add: { members, key, value in
            members.append(IntermediateObjectMember(name: key, value: value))
        },
        wrap: IntermediateValue.object
    )
}

private func dictf(_ params: [IntermediateValue]) throws -> IntermediateValue {
    try build(
        params: params,
        make: { count -> [String: Any] in
            var dict = [String: Any]()
            dict.reserveCapacity(count)
            return dict
        },
        add: { dict, key, value in
            dict[key] = value
        },
        wrap: IntermediateValue.dict
    )
}

private func build<T>(
    params: [IntermediateValue],
    make: (Int) -> T,
    add: (inout T, String, IntermediateValue) -> Void,
    wrap: (T) -> IntermediateValue
) throws -> IntermediateValue {
    guard params.count.isMultiple(of: 2) else {
        throw EvaluatorError.badFunctionParameters(params, "object requires an even number of parameters")
    }

    var output = make(params.count / 2)

    for keyIndex in stride(from: 0, to: params.endIndex, by: 2) {
        let keyValue = params[keyIndex]
        let value = params[keyIndex + 1]

        guard let key = keyValue.string else {
            throw EvaluatorError.badFunctionParameters(params, "object keys must be strings")
        }

        add(&output, key, value)
    }
    return wrap(output)
}

extension Callable {
    static let objectFunction = Callable.functionVarargs(.init(noContext: objectf(_:)))
    static let dictFunction = Callable.functionVarargs(.init(noContext: dictf(_:)))
}
