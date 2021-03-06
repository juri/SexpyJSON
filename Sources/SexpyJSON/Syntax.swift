struct SexpyJSONMember: Equatable {
    var name: String
    var value: SexpyJSONElement
}

struct SexpyJSONSymbol: Equatable {
    var name: String
}

extension SexpyJSONSymbol {
    init(_ name: String) {
        self.init(name: name)
    }
}

enum SExpression: Equatable {
    case empty
    case call(SExpressionCall)
}

struct SExpressionCall: Equatable {
    var target: SexpyJSONTarget
    var params: [SExpressionParameter]
}

indirect enum SexpyJSONTarget: Equatable {
    case symbol(SexpyJSONSymbol)
    case sexp(SExpression)
}

enum SExpressionParameter: Equatable {
    case element(SexpyJSONElement)
    case symbol(SexpyJSONSymbol)
}

enum SexpyJSONElement: Equatable {
    case string(String)
    case number(String)
    case array([SexpyJSONElement])
    case object([SexpyJSONMember])
    case boolean(Bool)
    case null

    case sexp(SExpression)
    case symbol(SexpyJSONSymbol)
}

// MARK: JSON syntax, other than arrays and objects

let openBrace = literal("{")
let closeBrace = literal("}")
let openBracket = literal("[")
let closeBracket = literal("]")
let quote = literal("\"")
let comma = literal(",")

let whitespace = prefix(
    while: { $0 == "\u{20}" || $0 == "\u{0A}" || $0 == "\u{0D}" || $0 == "\u{09}" }
)
.map { _ in () }

let oneNine = oneOf((0 ... 9).map(String.init).map(capturingLiteral(_:)))
let digit = oneOf([capturingLiteral("0"), oneNine])
let digits = zeroOrMore(digit, separatedBy: always(())).map { $0.joined() }
let unsignedInteger = zip(digit, digits).map { $0 + $1 }

let integer = oneOf([
    unsignedInteger,
    zip(literal("-"), unsignedInteger).map { "-\($0.1)" },
])

let fraction = zip(literal("."), unsignedInteger).map { ".\($0.1)" }
let exponent = zip(oneOf([capturingLiteral("e"), capturingLiteral("E")]), integer).map { "\($0.0)\($0.1)" }

let number = zip(
    integer,
    oneOf([
        fraction,
        literal("").map { "" },
    ]),
    oneOf([
        exponent,
        literal("").map { "" },
    ])
).map { "\($0)\($1)\($2)" }

let escaped = zip(literal("\\"), char).map { #"\\#($0.1)"# }
let notQuote = prefix(while: { $0 != "\"" && $0 != "\\" }).filter { !$0.isEmpty }.map(String.init)
let stringPart = oneOf([escaped, notQuote])
let stringContent = zeroOrMore(stringPart, separatedBy: always(())).map { $0.joined() }
let quoted = zip(quote, stringContent, quote).map(\.1)

let boolTrue = literal("true").map { true }
let boolFalse = literal("false").map { false }

let null = literal("null")

// MARK: Comment syntax

let lineComment = literal("#")
let commentedLineSuffix = zip(
    lineComment,
    prefix(while: { $0 != "\n" }).map { _ in () }
)
.map { _ in () }

let whitespaceOrComment = zeroOrMore(whitespace, separatedBy: commentedLineSuffix).map { _ in () }

// MARK: Sexp syntax

let openParen = literal("(")
let closeParen = literal(")")

private let restrictedOperators: Set<Character> = ["+", "-"]

private let specials: Set<Character> = ["*", "/", "#", "@", "$", "!", "%", "&", "?", "_", "<", ">", "="]
extension Character {
    fileprivate var isRestrictedOperator: Bool { restrictedOperators.contains(self) }
    fileprivate var isSpecial: Bool { specials.contains(self) }
}

let singleCharOperators = restrictedOperators.map {
    capturingLiteral(String($0)).map(SexpyJSONSymbol.init(name:))
}

private func canStartFunctionName(_ c: Character) -> Bool { c.isLetter || c.isSpecial }
private func canContinueFunctionName(_ c: Character) -> Bool {
    c.isLetter || c.isNumber || c.isSpecial || c.isRestrictedOperator
}

let symbol = oneOf(singleCharOperators + [
    zip(char.filter(canStartFunctionName(_:)), zeroOrMore(char.filter(canContinueFunctionName(_:)), separatedBy: always(())))
        .map { String([$0] + $1) }
        .map(SexpyJSONSymbol.init(name:)),
])

let symbolValue = symbol.map { sym in
    SexpyJSONElement.symbol(sym)
}

// MARK: Parser builder for recursive syntax

private func missingParser<T>(_ name: String) -> Parser<T> {
    Parser<T> { _ in
        assertionFailure("Parser missing: \(name)")
        return nil
    }
}

func buildParser() -> Parser<SexpyJSONElement> {
    let valueParser: RefBox<Parser<SexpyJSONElement>> = RefBox(value: missingParser("valueParser"))

    let valueOrSymbolParser: RefBox<Parser<SexpyJSONElement>> = RefBox(value: missingParser("valueOrSymbolParser"))

    let element: Parser<SexpyJSONElement> = wrapped {
        zip(whitespaceOrComment, valueOrSymbolParser.value, whitespaceOrComment).map(\.1)
    }

    let elements = zeroOrMore(element, separatedBy: comma)
    let array = zip(openBracket, elements, closeBracket).map(\.1).map(SexpyJSONElement.array)

    let memberName = zip(whitespaceOrComment, quoted, whitespaceOrComment).map(\.1)
    let member = zip(memberName, literal(":"), element)
    let members = zeroOrMore(member, separatedBy: comma)
    let object = zip(openBrace, members, closeBrace)
        .map(\.1)
        .map { mems -> SexpyJSONElement in
            let smems = mems.map { SexpyJSONMember(name: $0.0, value: $0.2) }
            return SexpyJSONElement.object(smems)
        }

    let sexpTargetParser: RefBox<Parser<SexpyJSONTarget>> = RefBox(value: missingParser("sexpTargetParser"))
    let sexpFunction = oneOf([
        symbol.map(SexpyJSONTarget.symbol),
        wrapped { sexpTargetParser.value },
    ])
    let sexpParameter = oneOf([
        wrapped { valueParser.value }.map(SExpressionParameter.element),
        symbol.map(SExpressionParameter.symbol),
    ])
    let callSExpContent = zip(
        sexpFunction,
        whitespaceOrComment,
        zeroOrMore(sexpParameter, separatedBy: whitespaceOrComment)
    )
    .map { ($0.0, $0.2) }

    let callSExp = zip(openParen, callSExpContent, closeParen)
        .map(\.1)
        .map { target, params in
            SExpression.call(.init(target: target, params: params))
        }
    let emptySExp = zip(openParen, whitespaceOrComment, closeParen)
        .map(const(SExpression.empty))
    let sexp = oneOf([callSExp, emptySExp])

    sexpTargetParser.value = sexp.map(SexpyJSONTarget.sexp)

    let valueBodyParser = oneOf([
        number.map(SexpyJSONElement.number),
        quoted.map(SexpyJSONElement.string),
        array,
        object,
        boolTrue.map(SexpyJSONElement.boolean),
        boolFalse.map(SexpyJSONElement.boolean),
        null.map { SexpyJSONElement.null },
        sexp.map(SexpyJSONElement.sexp),
    ])

    let valueBodyIgnoringWhitespace = zip(whitespaceOrComment, valueBodyParser, whitespaceOrComment).map(\.1)

    valueParser.value = valueBodyIgnoringWhitespace

    valueOrSymbolParser.value = oneOf([
        valueBodyIgnoringWhitespace,
        symbolValue,
    ])

    return valueOrSymbolParser.value
}
