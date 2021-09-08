struct Symbol: Equatable, Hashable {
    var name: String
}

indirect enum Expression: Equatable {
    case call(Call)
    case symbol(Symbol)
    case value(ExpressionValue)
}

extension Expression {
    var call: Call? {
        guard case let .call(c) = self else { return nil }
        return c
    }

    var symbol: Symbol? {
        guard case let .symbol(s) = self else { return nil }
        return s
    }

    var value: ExpressionValue? {
        guard case let .value(v) = self else { return nil }
        return v
    }
}

struct Call: Equatable {
    var target: Expression
    var params: [Expression]
}

extension Call {
    var allExpressions: [Expression] {
        [self.target] + self.params
    }

    init(expressions: [Expression]) {
        precondition(!expressions.isEmpty)
        guard let first = expressions.first else {
            preconditionFailure("expressions must not be empty")
        }

        self.init(target: first, params: Array(expressions.dropFirst()))
    }
}

enum ExpressionValue: Equatable {
    case string(String)
    case number(String)
    case array([Expression])
    case object([ExpressionObjectMember])
    case boolean(Bool)
    case null
    case expression(Expression)
}

extension ExpressionValue {
    var array: [Expression]? {
        guard case let .array(elems) = self else { return nil }
        return elems
    }
}

struct ExpressionObjectMember: Equatable {
    var name: String
    var value: Expression
}

extension Expression {
    init(element: SexpyJSONElement) {
        switch element {
        case let .string(string):
            self = .value(.string(string))
        case let .number(string):
            self = .value(.number(string))
        case let .array(array):
            self = .value(.array(array.map(Expression.init(element:))))
        case let .object(array):
            self = .value(.object(array.map(ExpressionObjectMember.init(sexpyJSONMember:))))
        case let .boolean(bool):
            self = .value(.boolean(bool))
        case .null:
            self = .value(.null)
        case let .sexp(sExpression):
            self = Expression(sExpression: sExpression)
        case let .symbol(symbol):
            self = .symbol(Symbol(sexpyJSONSymbol: symbol))
        }
    }

    init(sExpression: SExpression) {
        switch sExpression {
        case .empty:
            self = .value(.null)
        case let .call(scall):
            switch scall.target {
            case let .symbol(symbol):
                let params = scall.params.map(Expression.init(sExpressionParameter:))
                self = .call(Call(target: .symbol(Symbol(sexpyJSONSymbol: symbol)), params: params))
            case let .sexp(e):
                self = .call(Call(target: Expression(sExpression: e), params: scall.params.map(Expression.init(sExpressionParameter:))))
            }
        }
    }

    init(sexpyJSONTarget: SexpyJSONTarget) {
        switch sexpyJSONTarget {
        case let .symbol(sexpyJSONSymbol):
            self = .symbol(Symbol(sexpyJSONSymbol: sexpyJSONSymbol))
        case let .sexp(sExpression):
            self = Expression(sExpression: sExpression)
        }
    }

    init(sExpressionParameter: SExpressionParameter) {
        switch sExpressionParameter {
        case let .element(sexpyJSONElement):
            self = Expression(element: sexpyJSONElement)
        case let .symbol(sexpyJSONSymbol):
            self = .symbol(Symbol(sexpyJSONSymbol: sexpyJSONSymbol))
        }
    }
}

extension ExpressionObjectMember {
    init(sexpyJSONMember: SexpyJSONMember) {
        self.init(
            name: sexpyJSONMember.name,
            value: Expression(element: sexpyJSONMember.value)
        )
    }
}

extension Symbol {
    init(_ name: String) {
        self.init(name: name)
    }

    init(sexpyJSONSymbol: SexpyJSONSymbol) {
        self.init(name: sexpyJSONSymbol.name)
    }
}
