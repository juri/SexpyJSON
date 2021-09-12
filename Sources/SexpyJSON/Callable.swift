enum Callable {
    case function1(Function1)
    case function2(Function2)
    case functionVarargs(FunctionVarargs)
    case specialOperator(SpecialOperator)

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        switch self {
        case let .specialOperator(fun):
            return try fun.call(params, context: &context)
        case let .function1(fun):
            return try fun.call(params, context: &context)
        case let .function2(fun):
            return try fun.call(params, context: &context)
        case let .functionVarargs(fun):
            return try fun.call(params, context: &context)
        }
    }

    func callFunction(_ params: [IntermediateValue], context: inout Context) throws -> IntermediateValue {
        switch self {
        case .specialOperator:
            throw EvaluatorError.badCallTarget(.callable(self))
        case let .function1(fun):
            return try fun.call(params)
        case let .function2(fun):
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

    func call(_ params: [IntermediateValue]) throws -> IntermediateValue {
        guard params.count == 1 else {
            throw EvaluatorError.badFunctionParameters(params, "\(self.name) requires one argument")
        }

        return try self.f(params[0])
    }
}

struct Function2 {
    let f: (IntermediateValue, IntermediateValue, inout Context) throws -> IntermediateValue
    let name: String

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        guard params.count == 2 else {
            throw EvaluatorError.badParameterList(params, "\(self.name) requires two arguments")
        }
        let param1Value = try evaluate(expression: params[0], in: &context)
        let param2Value = try evaluate(expression: params[1], in: &context)

        return try self.f(param1Value, param2Value, &context)
    }

    func call(_ params: [IntermediateValue], context: inout Context) throws -> IntermediateValue {
        guard params.count == 2 else {
            throw EvaluatorError.badFunctionParameters(params, "\(self.name) requires two arguments")
        }

        return try self.f(params[0], params[1], &context)
    }
}

extension Function2 {
    init(noContext f: @escaping (IntermediateValue, IntermediateValue) throws -> IntermediateValue, name: String) {
        self.init(f: { p1, p2, _ in try f(p1, p2) }, name: name)
    }
}

struct FunctionVarargs {
    let f: ([IntermediateValue], Context) throws -> IntermediateValue

    func call(_ params: [Expression], context: inout Context) throws -> IntermediateValue {
        let paramValues = try params.map { try evaluate(expression: $0, in: &context) }
        return try self.f(paramValues, context)
    }

    func call(_ params: [IntermediateValue], context: inout Context) throws -> IntermediateValue {
        try self.f(params, context)
    }
}

extension FunctionVarargs {
    init(noContext f: @escaping ([IntermediateValue]) throws -> IntermediateValue) {
        self.init(f: { params, _ in try f(params) })
    }
}
