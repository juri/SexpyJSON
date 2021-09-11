enum Callable {
    case function1(Function1)
    case functionVarargs(FunctionVarargs)
    case specialOperator(SpecialOperator)
    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        switch self {
        case let .specialOperator(fun):
            return try fun.call(params, context: &context)
        case let .function1(fun):
            return try fun.call(params, context: &context)
        case let .functionVarargs(fun):
            return try fun.call(params, context: &context)
        }
    }
}

struct SpecialOperator {
    let f: ([Expression], inout Context) throws -> IntermediateValue

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        try self.f(params, &context)
    }
}

struct Function1 {
    let f: (IntermediateValue) throws -> IntermediateValue
    let name: String

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        guard params.count == 1 else {
            throw EvaluatorError.badParameterList(params, "\(self.name) requires one argument")
        }
        let paramValue = try evaluate(expression: params[0], in: &context)

        return try self.f(paramValue)
    }
}

struct FunctionVarargs {
    let f: ([IntermediateValue]) throws -> IntermediateValue

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        let paramValues = try params.map { try evaluate(expression: $0, in: &context) }
        return try self.f(paramValues)
    }
}
