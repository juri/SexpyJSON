/* fundoc name
 has-name
 */

/* fundoc example
 (let (a 10) (has-name "a"))
 */

/* fundoc expect
 true
 */

/* fundoc example
 (let (a 10) (has-name "b"))
 */

/* fundoc expect
 false
 */

/* fundoc text
 The `has-name` function returns true if the string given as an argument is a name of an existing value.
 You can access it with the <<_name>> or <<nameOpt>> function.
 */

private func hasName(_ nameValue: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .string(s) = nameValue else {
        throw EvaluatorError.badFunctionParameters([nameValue], "Bad name type: \(nameValue)")
    }
    guard (try? context.value(for: Symbol(s))) != nil else {
        return .boolean(false)
    }
    return .boolean(true)
}

/* fundoc name
 name
 */

/* fundoc example
 (let (a 10) (name "a"))
 */

/* fundoc expect
 10
 */

/* fundoc text
 The `name` function returns the value bound to the name in the current lexical scope. If the name doesn't exist,
 an error is raised. You can check for the name's existence with <<_has_name>> function or return null
 in case of a non-existent name with <<nameOpt>>.
 */

private func name(_ nameValue: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .string(s) = nameValue else {
        throw EvaluatorError.badFunctionParameters([nameValue], "Bad name type: \(nameValue)")
    }
    guard let value = try? context.value(for: Symbol(s)) else {
        throw EvaluatorError.badFunctionParameters([nameValue], "Unrecognized name: '\(s)'")
    }
    return value
}

/* fundoc id
 nameOpt
 */

/* fundoc name
 name?
 */

/* fundoc example
 (let (a 10) (name? "a"))
 */

/* fundoc expect
 10
 */

/* fundoc example
 (let (a 10) (name? "b"))
 */

/* fundoc expect
 null
 */

/* fundoc text
 The `name?` function returns the value bound to the name in the current lexical scope. If the name doesn't exist,
 it returns null. You can check for the name's existence with <<_has_name>> function or cause an error to be
 raised in case of an nonexistent name with <<_name>>.
 */

private func nameOpt(_ nameValue: IntermediateValue, _ context: inout Context) throws -> IntermediateValue {
    guard case let .string(s) = nameValue else {
        throw EvaluatorError.badFunctionParameters([nameValue], "Bad name type: \(nameValue)")
    }
    return (try? context.value(for: Symbol(s))) ?? .null
}

extension Callable {
    static let hasNameFunction = Callable.function1(.init(f: hasName(_:_:), name: "has-name"))
    static let nameFunction = Callable.function1(.init(f: name(_:_:), name: "name"))
    static let nameOptFunction = Callable.function1(.init(f: nameOpt(_:_:), name: "name?"))
}
