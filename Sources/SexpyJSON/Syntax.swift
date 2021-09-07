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


let oneNine = oneOf((0...9).map(String.init).map(capturingLiteral(_:)))
let digit = oneOf([capturingLiteral("0"), oneNine])
let digits = zeroOrMore(digit, separatedBy: always(())).map { $0.joined() }
let unsignedInteger = zip(digit, digits).map { $0 + $1 }

let integer = oneOf([
    unsignedInteger,
    zip(literal("-"), unsignedInteger).map { "-\($0.1)" }
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
let stringContent = oneOrMore(stringPart, separatedBy: always(())).map { $0.joined() }
let quoted = zip(quote, stringContent, quote).map(\.1)

let boolTrue = literal("true").map { true }
let boolFalse = literal("false").map { false }

let null = literal("null")

// MARK: Sexp syntax

// sexp := (target p1 p2 p3)
// target := + | - | * | / | sexp

let openParen = literal("(")
let closeParen = literal(")")

private let specials: Set<Character> = ["+", "-", "*", "/", "#", "@", "$", "!", "%", "&", "?", "_"]
private extension Character {
    var isSpecial: Bool { specials.contains(self) }
}

let symbol = oneOf([
    capturingLiteral("+").map(SexpyJSONSymbol.init(name:)),
    capturingLiteral("-").map(SexpyJSONSymbol.init(name:)),
    capturingLiteral("*").map(SexpyJSONSymbol.init(name:)),
    capturingLiteral("/").map(SexpyJSONSymbol.init(name:)),
    
    zip(char.filter { $0.isLetter || $0 == "_" }, zeroOrMore(char.filter { $0.isLetter || $0.isNumber || $0.isSpecial }, separatedBy: always(())))
        .map { String([$0] + $1) }
        .map(SexpyJSONSymbol.init(name:))
])

let symbolValue = symbol.map { sym in
    SexpyJSONElement.symbol(sym)
}

// MARK: Parser builder for recursive syntax

func buildParser() -> Parser<SexpyJSONElement> {
    let valueParser: RefBox<Parser<SexpyJSONElement>> = RefBox(value: Parser { _ in fatalError() })

    let valueOrSymbolParser: RefBox<Parser<SexpyJSONElement>> = RefBox(value: Parser { _ in fatalError() })


    let element: Parser<SexpyJSONElement> = wrapped {
        zip(whitespace, valueOrSymbolParser.value, whitespace).map(\.1)
    }

    let elements = zeroOrMore(element, separatedBy: comma)
    let array = zip(openBracket, elements, closeBracket).map(\.1).map(SexpyJSONElement.array)
    
    let memberName = zip(whitespace, quoted, whitespace).map(\.1)
    let member = zip(memberName, literal(":"), element)
    let members = zeroOrMore(member, separatedBy: comma)
    let object = zip(openBrace, members, closeBrace)
        .map(\.1)
        .map { mems -> SexpyJSONElement in
            let smems = mems.map { SexpyJSONMember(name: $0.0, value: $0.2) }
            return SexpyJSONElement.object(smems)
        }
    
    let sexpTargetParser: RefBox<Parser<SexpyJSONTarget>> = RefBox(value: Parser { _ in fatalError() })
    let sexpFunction = oneOf([
        symbol.map(SexpyJSONTarget.symbol),
        wrapped({ sexpTargetParser.value }),
    ])
    let sexpParameter = oneOf([
        wrapped({ valueParser.value }).map(SExpressionParameter.element),
        symbol.map(SExpressionParameter.symbol),
    ])
    let callSExpContent = zip(sexpFunction, whitespace, zeroOrMore(sexpParameter, separatedBy: whitespace))
        .map { ($0.0, $0.2) }

    let callSExp = zip(openParen, callSExpContent, closeParen)
        .map(\.1)
        .map { target, params in
            SExpression.call(.init(target: target, params: params))
        }
    let emptySExp = zip(openParen, whitespace, closeParen)
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
//        symbolValue,
//        symbol.map { SexpyJSONElement.sexp(.call(.init(target: .symbol(.name("value")), params: [.symbol(.name($0))])))},
    ])

    let valueBodyIgnoringWhitespace = zip(whitespace, valueBodyParser, whitespace).map(\.1)

    valueParser.value = valueBodyIgnoringWhitespace

    valueOrSymbolParser.value = oneOf([
        valueBodyIgnoringWhitespace,
        symbolValue,
    ])

    return valueOrSymbolParser.value
}
