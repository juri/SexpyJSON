let builtins: [Symbol: IntermediateValue] = [
    .addition: .function(.addFunction),
    .division: .function(.divideFunction),
    .multiplication: .function(.multiplyFunction),
    .subtraction: .function(.subtractFunction),
    .name("concat"): .function(.concatFunction),
    .name("eq"): .function(.eqFunction),
    .name("fn"): .function(.fnFunction),
    .name("if"): .function(.ifFunction),
    .name("let"): .function(.letFunction),
]
