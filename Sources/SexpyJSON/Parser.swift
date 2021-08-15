import Foundation

public struct Parser<A> {
    public let run: (inout Substring) -> A?

    public init(run: @escaping (inout Substring) -> A?) {
        self.run = run
    }
}

public extension Parser {
    func run(_ str: String) -> (match: A?, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }

    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
        Parser<B> { str -> B? in
            self.run(&str).map(f)
        }
    }

    func filter(_ f: @escaping (A) -> Bool) -> Parser<A> {
        Parser<A> { str -> A? in
            self.run(&str).flatMap { f($0) ? $0 : nil }
        }
    }

    func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        Parser<B> { str -> B? in
            let original = str
            let matchA = self.run(&str)
            let parserB = matchA.map(f)
            guard let matchB = parserB?.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }
    
    func debug(_ f: @escaping (A?, Substring) -> Void) -> Parser<A> {
        Parser<A> { str -> A? in
            let result = self.run(&str)
            f(result, str)
            return result
        }
    }
}

public let char = Parser<Character> { str in
    guard !str.isEmpty else { return nil }
    return str.removeFirst()
}

public func literal(_ p: String) -> Parser<Void> {
    Parser<Void> { str in
        guard str.hasPrefix(p) else { return nil }
        str.removeFirst(p.count)
        return ()
    }
}

public func capturingLiteral(_ p: String) -> Parser<String> {
    Parser<String> { str in
        guard str.hasPrefix(p) else { return nil }
        str.removeFirst(p.count)
        return String(p)
    }
}

public func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
    Parser<Substring> { str in
        let prefix = str.prefix(while: p)
        str.removeFirst(prefix.count)
        return prefix
    }
}

public func prefix(length: Int) -> Parser<Substring> {
    Parser<Substring> { str in
        let prefix = str.prefix(length)
        guard prefix.count == length else { return nil }
        str.removeFirst(length)
        return prefix
    }
}

public func always<A>(_ a: A) -> Parser<A> {
    Parser<A> { _ in a }
}

public func oneOf<A>(_ parsers: [Parser<A>]) -> Parser<A> {
    Parser<A> { str in
        for parser in parsers {
            if let match = parser.run(&str) {
                return match
            }
        }
        return nil
    }
}

public func zeroOrMore<A>(_ p: Parser<A>, separatedBy s: Parser<Void>) -> Parser<[A]> {
    Parser<[A]> { str in
        var original = str
        var matches: [A] = []
        while let match = p.run(&str) {
            original = str
            matches.append(match)
            guard s.run(&str) != nil else {
                return matches
            }
        }
        str = original
        return matches
    }
}

public func oneOrMore<A>(_ p: Parser<A>, separatedBy s: Parser<Void>) -> Parser<[A]> {
    Parser<[A]> { str -> [A]? in
        guard let match = p.run(&str) else {
            return nil
        }
        guard s.run(&str) != nil else {
            return [match]
        }
        if let rest = zeroOrMore(p, separatedBy: s).run(&str) {
            return [match] + rest
        }
        return [match]
    }
}

public func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
    Parser<(A, B)> { str -> (A, B)? in
        let original = str
        guard let matchA = a.run(&str) else { return nil }
        guard let matchB = b.run(&str) else {
            str = original
            return nil
        }
        return (matchA, matchB)
    }
}

public func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
) -> Parser<(A, B, C)> {
    zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

func wrapped<A>(_ p: @escaping () -> Parser<A>) -> Parser<A> {
    Parser<A> { str in
        p().run(&str)
    }
}


func debugging<A>(_ f: @escaping (Substring) -> Void, parser: Parser<A>) -> Parser<A> {
    Parser<A> { str in
        f(str)
        return parser.run(&str)
    }
}
