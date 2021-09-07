let builtins: [Symbol: IntermediateValue] = [
    Symbol("+"): .function(.addFunction),
    Symbol("/"): .function(.divideFunction),
    Symbol("*"): .function(.multiplyFunction),
    Symbol("-"): .function(.subtractFunction),
    Symbol("concat"): .function(.concatFunction),
    Symbol("define"): .function(.defineFunction),
    Symbol("eq"): .function(.eqFunction),
    Symbol("fn"): .function(.fnFunction),
    Symbol("if"): .function(.ifFunction),
    Symbol("let"): .function(.letFunction),
]
