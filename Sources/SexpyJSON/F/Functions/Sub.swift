/* fundoc name
 sub
 */

/* fundoc example
 (sub ["foo", "bar", "zap", "bang"] 2)
 */

/* fundoc expect
 "zap"
 */

/* fundoc example
 (sub {"key1": "value1", "key2": "value2"} "key2")
 */

/* fundoc expect
 "value2"
 */

/* fundoc example
 (sub {"key1": {"nestedKey1": "nestedValue1"}} "key1" "nestedKey1")
 */

/* fundoc expect
 "nestedValue1"
 */

/* fundoc text
 The `sub` function is the subscription operator. It allows you to retrieve a member of an array (with an index)
 or an object (with a string). See also <<subopt>>.
 */

private func subf(_ params: [IntermediateValue]) throws -> IntermediateValue {
    guard let container = params.first,
          case let subscripts = params.dropFirst(),
          let firstSubscript = subscripts.first,
          case let restSubscripts = subscripts.dropFirst()
    else {
        throw EvaluatorError.badFunctionParameters(params, "The sub function at least two parameters")
    }

    return try subChild(container, firstSubscript, restSubscripts, optional: false)
}

/* fundoc name
 sub?
 */

/* fundoc id
 subopt
 */

/* fundoc example
 (sub? {"key1": {"nestedKey1": "nestedValue1"}} "key1" "nestedKey1")
 */

/* fundoc expect
 "nestedValue1"
 */

/* fundoc example
 (sub? {"key1": {"nestedKey1": "nestedValue1"}} "key2" "nestedKey1")
 */

/* fundoc expect
 null
 */

/* fundoc text
 The `sub?` function is the subscription operator with support for conditional container. It allows you
 to retrieve a member of an array (with an index) or an object (with a string), and returns null if the
 container is null. See also <<_sub>>.
 */

private func subOptf(_ params: [IntermediateValue]) throws -> IntermediateValue {
    guard let container = params.first,
          case let subscripts = params.dropFirst(),
          let firstSubscript = subscripts.first,
          case let restSubscripts = subscripts.dropFirst()
    else {
        throw EvaluatorError.badFunctionParameters(params, "The sub function at least two parameters")
    }

    return try subChild(container, firstSubscript, restSubscripts, optional: true)
}

private func subChild(
    _ container: IntermediateValue,
    _ headSub: IntermediateValue,
    _ tail: ArraySlice<IntermediateValue>,
    optional: Bool
) throws -> IntermediateValue {
    if optional, case .null = container { return .null }
    let value = try subValue(container, headSub)
    if let tailHead = tail.first {
        return try subChild(value, tailHead, tail.dropFirst(), optional: optional)
    }
    return value
}

private func subValue(_ container: IntermediateValue, _ sub: IntermediateValue) throws -> IntermediateValue {
    switch container {
    case let .array(arr):
        guard case let .integer(index) = sub else {
            throw EvaluatorError.badFunctionParameters([container, sub], "The sub function requires an integer to subscript arrays")
        }
        guard index >= 0, arr.endIndex > index else {
            throw EvaluatorError.badFunctionParameters([container, sub], "Index \(index) out of bounds for array of \(arr.count) elements")
        }
        return arr[index]
    case let .nativeArray(arr):
        guard case let .integer(index) = sub else {
            throw EvaluatorError.badFunctionParameters([container, sub], "The sub function requires second parameter to be an integer for arrays")
        }
        guard index >= 0, arr.endIndex > index else {
            throw EvaluatorError.badFunctionParameters([container, sub], "Index \(index) out of bounds for array of \(arr.count) elements")
        }
        return try IntermediateValue.tryInit(nativeValue: arr[index])
    case let .object(members):
        guard case let .string(key) = sub else {
            throw EvaluatorError.badFunctionParameters([container, sub], "The sub function requires second parameter to be a string for objects")
        }
        return members.first(where: { $0.name == key })?.value ?? .null
    case let .dict(dict):
        guard case let .string(key) = sub else {
            throw EvaluatorError.badFunctionParameters([container, sub], "The sub function requires second parameter to be a string for objects")
        }
        return try IntermediateValue(nativeValue: dict[key])
    default:
        throw EvaluatorError.badFunctionParameters([container, sub], "The sub function requires first parameter to be an array or object")
    }
}

extension Callable {
    static let subFunction = Callable.functionVarargs(.init(noContext: subf(_:)))
    static let subOptFunction = Callable.functionVarargs(.init(noContext: subOptf(_:)))
}
