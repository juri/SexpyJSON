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

/* fundoc text
 The `sub` function is the subscription operator. It allows you to retrieve a member of an array (with an index)
 or an object (with a string).
 */

private func subf(_ container: IntermediateValue, _ subs: IntermediateValue) throws -> IntermediateValue {
    switch container {
    case let .array(arr):
        guard case let .integer(index) = subs else {
            throw EvaluatorError.badFunctionParameters([container, subs], "The sub function requires second parameter to be an integer for arrays")
        }
        guard index >= 0, arr.endIndex > index else {
            throw EvaluatorError.badFunctionParameters([container, subs], "Index \(index) out of bounds for array of \(arr.count) elements")
        }
        return arr[index]
    case let .nativeArray(arr):
        guard case let .integer(index) = subs else {
            throw EvaluatorError.badFunctionParameters([container, subs], "The sub function requires second parameter to be an integer for arrays")
        }
        guard index >= 0, arr.endIndex > index else {
            throw EvaluatorError.badFunctionParameters([container, subs], "Index \(index) out of bounds for array of \(arr.count) elements")
        }
        return try IntermediateValue.tryInit(nativeValue: arr[index])
    case let .object(members):
        guard case let .string(key) = subs else {
            throw EvaluatorError.badFunctionParameters([container, subs], "The sub function requires second parameter to be a string for objects")
        }
        return members.first(where: { $0.name == key })?.value ?? .null
    case let .dict(dict):
        guard case let .string(key) = subs else {
            throw EvaluatorError.badFunctionParameters([container, subs], "The sub function requires second parameter to be a string for objects")
        }
        return try IntermediateValue(nativeValue: dict[key])
    default:
        throw EvaluatorError.badFunctionParameters([container, subs], "The sub function requires first parameter to be an array or object")
    }
}

extension Callable {
    static let subFunction = Callable.function2(Function2(noContext: subf(_:_:), name: "sub"))
}
