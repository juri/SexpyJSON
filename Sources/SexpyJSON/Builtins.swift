let builtins: [Symbol: IntermediateValue] = [
    Symbol("+"): .callable(.addFunction),
    Symbol("/"): .callable(.divideFunction),
    Symbol("*"): .callable(.multiplyFunction),
    Symbol("-"): .callable(.subtractFunction),
    Symbol("%"): .callable(.moduloFunction),
    Symbol(">"): .callable(.gtFunction),
    Symbol(">="): .callable(.gteFunction),
    Symbol("<"): .callable(.ltFunction),
    Symbol("<="): .callable(.lteFunction),
    Symbol("??"): .callable(.nonNullOrFunction),
    Symbol("apply"): .callable(.applyFunction),
    Symbol("as-dict"): .callable(.asDictFunction),
    Symbol("as-object"): .callable(.asObjectFunction),
    Symbol("ceil"): .callable(.ceilFunction),
    Symbol("concat"): .callable(.concatFunction),
    Symbol("cond"): .callable(.condFunction),
    Symbol("define"): .callable(.defineFunction),
    Symbol("dict"): .callable(.dictFunction),
    Symbol("double"): .callable(.doubleFunction),
    Symbol("eq"): .callable(.eqFunction),
    Symbol("filter"): .callable(.filterFunction),
    Symbol("flatmap"): .callable(.flatmapFunction),
    Symbol("floor"): .callable(.floorFunction),
    Symbol("fn"): .callable(.fnFunction),
    Symbol("if"): .callable(.ifFunction),
    Symbol("int"): .callable(.intFunction),
    Symbol("is-null"): .callable(.isNullFunction),
    Symbol("join-string"): .callable(.joinStringFunction),
    Symbol("len"): .callable(.lenFunction),
    Symbol("let"): .callable(.letFunction),
    Symbol("map"): .callable(.mapFunction),
    Symbol("merge"): .callable(.mergeFunction),
    Symbol("not"): .callable(.notFunction),
    Symbol("object"): .callable(.objectFunction),
    Symbol("round"): .callable(.roundFunction),
    Symbol("sub"): .callable(.subFunction),
    Symbol("sub?"): .callable(.subOptFunction),
    Symbol("trunc"): .callable(.truncFunction),
]
