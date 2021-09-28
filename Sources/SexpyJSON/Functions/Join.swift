/* fundoc name
 join-string
 */

/* fundoc example
 (join ", " ["hello", "world"])
 */

/* fundoc expect
 "hello, world"
 */

/* fundoc text
 The `join-string` function joins an array of strings into a single string using a separator. The first
 parameter is the separator string, the second parameter the array.
 */

private func joinsf(_ separator: IntermediateValue, _ elements: IntermediateValue) throws -> IntermediateValue {
    guard let separatorString = separator.string else {
        throw EvaluatorError.badFunctionParameters(
            [separator, elements], "First parameter to join-string must be a string"
        )
    }

    guard let elementsArray = try elements.anyArray else {
        throw EvaluatorError.badFunctionParameters(
            [separator, elements], "Second parameter to join-string must be a string array"
        )
    }

    let elementStrings: [String] = try elementsArray.map {
        guard let str = $0.string else {
            throw EvaluatorError.badFunctionParameters(
                [separator, elements], "Second parameter to join-string must be a string array"
            )
        }
        return str
    }

    return .string(elementStrings.joined(separator: separatorString))
}

extension Callable {
    static let joinStringFunction = Callable.function2(.init(noContext: joinsf(_:_:), name: "join-string"))
}
