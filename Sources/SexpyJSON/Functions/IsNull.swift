/* fundoc name
 is-null
 */

/* fundoc example
 (is-null null)
 */

/* fundoc expect
 true
 */

/* fundoc example
 (is-null "asdf")
 */

/* fundoc expect
 false
 */

/* fundoc text
 The `is-null` function returns true if its sole parameter is null.
 */

private func isNullf(_ value: IntermediateValue) -> IntermediateValue {
    if case .null = value { return .boolean(true) }
    return .boolean(false)
}

extension Callable {
    static let isNullFunction = Callable.function1(Function1(f: isNullf(_:), name: "is-null"))
}
