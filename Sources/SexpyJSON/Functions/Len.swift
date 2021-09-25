/* fundoc name
 len
 */

/* fundoc example
 (len [1, 2, 3, 4])
 */

/* fundoc expect
 4
 */

/* fundoc example
 (len "foo")
 */

/* fundoc expect
 3
 */

/* fundoc text
 The `len` function returns the lenght of an array or a string.
 */

private func lenf(_ param: IntermediateValue) throws -> IntermediateValue {
    switch param {
    case let .string(s): return .integer(s.count)
    case let .array(a): return .integer(a.count)
    case let .nativeArray(a): return .integer(a.count)
    default:
        throw EvaluatorError.badFunctionParameters([param], "len requires string or array argument")
    }
}

extension Callable {
    static let lenFunction = Callable.function1(Function1(f: lenf, name: "len"))
}
