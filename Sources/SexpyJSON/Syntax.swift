import Foundation

struct SexpyJSONMember: Equatable {
    var name: String
    var value: SexpyJSONElement
}

enum SexpyJSONElement: Equatable {
    case string(String)
    case integer(Int)
    case array([SexpyJSONElement])
    case object([SexpyJSONMember])
    case boolean(Bool)
}

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

func parseInt(_ a: String) -> Parser<Int> {
    Parser { _ in Int(a) }
}

// TODO: fraction, exponent

let escaped = zip(literal("\\"), char).map { #"\\#($0.1)"# }
let notQuote = prefix(while: { $0 != "\"" && $0 != "\\" }).filter { !$0.isEmpty }.map(String.init)
let stringPart = oneOf([escaped, notQuote])
let stringContent = oneOrMore(stringPart, separatedBy: always(())).map { $0.joined() }
let quoted = zip(quote, stringContent, quote).map(\.1)

let boolTrue = literal("true").map { true }
let boolFalse = literal("false").map { false }


func buildParser() -> Parser<SexpyJSONElement> {
    let valueParser: RefBox<Parser<SexpyJSONElement>> = RefBox(value: Parser { _ in fatalError() })

    let element: Parser<SexpyJSONElement> = wrapped {
        zip(whitespace, valueParser.value, whitespace).map(\.1)
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
    
    valueParser.value = oneOf([
        integer.flatMap(parseInt).map(SexpyJSONElement.integer),
        quoted.map(SexpyJSONElement.string),
        array,
        object,
        boolTrue.map(SexpyJSONElement.boolean),
        boolFalse.map(SexpyJSONElement.boolean),
    ])

    return valueParser.value
}
