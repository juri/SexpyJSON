func const<A, B>(_ value: A) -> (B) -> A {
    { _ in value }
}

func pipe<A, B, C>(_ f1: @escaping (A) -> B, _ f2: @escaping (B) -> C) -> (A) -> C {
    { a in f2(f1(a)) }
}
