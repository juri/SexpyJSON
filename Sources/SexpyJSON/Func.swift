func const<A, B>(_ value: A) -> (B) -> A {
    { _ in value }
}
