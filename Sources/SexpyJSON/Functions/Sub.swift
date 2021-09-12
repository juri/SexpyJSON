private func subf(_ container: IntermediateValue, _ subs: IntermediateValue, _: inout Context) throws -> IntermediateValue {
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
    default:
        throw EvaluatorError.badFunctionParameters([container, subs], "The sub function requires first parameter to be an array or object")
    }
}

extension Callable {
    static let subFunction = Callable.function2WithContext(FunctionWithContext2(f: subf(_:_:_:), name: "sub"))
}
