enum Symbol: Equatable, Hashable {
    case addition
    case subtraction
    case multiplication
    case division
    case name(String)
}

extension Symbol {
    var name: String? {
        guard case let .name(n) = self else { return nil }
        return n
    }
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
        case .string(let string):
            self = .value(.string(string))
        case .number(let string):
            self = .value(.number(string))
        case .array(let array):
            self = .value(.array(array.map(Expression.init(element:))))
        case .object(let array):
            self = .value(.object(array.map(ExpressionObjectMember.init(sexpyJSONMember:))))
        case .boolean(let bool):
            self = .value(.boolean(bool))
        case .null:
            self = .value(.null)
        case .sexp(let sExpression):
            self = Expression(sExpression: sExpression)
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
    init(sexpyJSONSymbol: SexpyJSONSymbol) {
        switch sexpyJSONSymbol {
        case .addition:
            self = .addition
        case .subtraction:
            self = .subtraction
        case .multiplication:
            self = .multiplication
        case .division:
            self = .division
        case let .name(string):
            self = .name(string)
        }
    }
}

