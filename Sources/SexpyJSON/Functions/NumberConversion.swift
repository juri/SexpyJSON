/* fundoc name
 round
 */

/* fundoc example
 (round 12.4)
 */

/* fundoc expect
 12.0
  */

/* fundoc example
 (round 12.5)
 */

/* fundoc expect
 13.0
  */

/* fundoc example
 (round -12.5)
 */

/* fundoc expect
 -13.0
  */

/* fundoc text
 The `round` function rounds its parameter number away from zero. It does not change
 the number's type.
 */

private func roundf(_ value: IntermediateValue) throws -> IntermediateValue {
    try calc(value: value, name: "round", rule: .toNearestOrAwayFromZero)
}

/* fundoc name
 trunc
 */

/* fundoc example
 (trunc 14.4)
 */

/* fundoc expect
 14.0
  */

/* fundoc example
 (trunc 14.5)
 */

/* fundoc expect
 14.0
  */

/* fundoc example
 (trunc -14.5)
 */

/* fundoc expect
 -14.0
  */

/* fundoc text
 The `trunc` function truncates its parameter number to the nearest integer that's
 closer to zero. It does not change the number's type.
 */

private func truncf(_ value: IntermediateValue) throws -> IntermediateValue {
    try calc(value: value, name: "trunc", rule: .towardZero)
}

/* fundoc name
 ceil
 */

/* fundoc example
 (ceil 16.4)
 */

/* fundoc expect
 17.0
  */

/* fundoc example
 (ceil 16.5)
 */

/* fundoc expect
 17.0
  */

/* fundoc example
 (ceil -16.5)
 */

/* fundoc expect
 -16.0
  */

/* fundoc text
 The `ceil` function rounds its parameter to the nearest larger integer. It does not change
 the number's type.
 */

private func ceilf(_ value: IntermediateValue) throws -> IntermediateValue {
    try calc(value: value, name: "ceil", rule: .up)
}

/* fundoc name
 floor
 */

/* fundoc example
 (floor 18.4)
 */

/* fundoc expect
 18.0
  */

/* fundoc example
 (floor 18.5)
 */

/* fundoc expect
 18.0
  */

/* fundoc example
 (floor -18.5)
 */

/* fundoc expect
 -19.0
  */

/* fundoc text
 The `floor` function rounds its parameter to the nearest smaller integer. It does not change
 the number's type.
 */

private func floorf(_ value: IntermediateValue) throws -> IntermediateValue {
    try calc(value: value, name: "floor", rule: .down)
}

private func calc(value: IntermediateValue, name: String, rule: FloatingPointRoundingRule) throws -> IntermediateValue {
    switch value {
    case let .integer(i): return .integer(i)
    case let .double(d): return .double(d.rounded(rule))
    default: throw EvaluatorError.badFunctionParameters([value], "The \(name) function requires a number argument")
    }
}

/* fundoc name
 int
 */

/* fundoc example
 (int 12.4)
 */

/* fundoc expect
 12
  */

/* fundoc example
 (int 12.5)
 */

/* fundoc expect
 12
  */

/* fundoc example
 (int -12.5)
 */

/* fundoc expect
 -12.0
  */

/* fundoc text
 The `int` function truncates its parameter to the nearest integer that's closer to zero.
 Its return value is an integer.
 */

private func intf(_ value: IntermediateValue) throws -> IntermediateValue {
    switch value {
    case let .integer(i): return .integer(i)
    case let .double(d): return .integer(Int(d.rounded(.towardZero)))
    default: throw EvaluatorError.badFunctionParameters([value], "The int function requires a number argument")
    }
}

/* fundoc name
 double
 */

/* fundoc example
 (double 12)
 */

/* fundoc expect
 12.0
  */

/* fundoc example
 (double -12)
 */

/* fundoc expect
 -12.0
  */

/* fundoc text
 The `double` function converts its number parameter to double.
 */

private func doublef(_ value: IntermediateValue) throws -> IntermediateValue {
    switch value {
    case let .integer(i): return .double(Double(i))
    case let .double(d): return .double(d)
    default: throw EvaluatorError.badFunctionParameters([value], "The double function requires a number argument")
    }
}

extension Callable {
    static let roundFunction = Callable.function1(.init(f: roundf(_:), name: "round"))
    static let truncFunction = Callable.function1(.init(f: truncf(_:), name: "trunc"))
    static let ceilFunction = Callable.function1(.init(f: ceilf(_:), name: "ceil"))
    static let floorFunction = Callable.function1(.init(f: floorf(_:), name: "floor"))

    static let intFunction = Callable.function1(.init(f: intf(_:), name: "int"))
    static let doubleFunction = Callable.function1(.init(f: doublef(_:), name: "double"))
}
