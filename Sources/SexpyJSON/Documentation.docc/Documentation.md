# ``SexpyJSON``

SexpyJSON is a Swift library for templating JSON with a language that is a mix of JSON and Lisp-like
S-expressions.

## Overview

This library documentation mostly covers the Swift library and associated tools. Documentation covering
details of the language are available in the repository and can be generated separately, or can be 
[viewed online](https://juri.github.io/SexpyJSON/).

A SexpyJSON document contains one JSON object or one S-expression. It produces one JSON object or JSON fragment.

```
{
    "key": (merge
        {"a": "bb"}
        {"c": (concat "d" "d")})
}
```

```
(let (name "Ishmael")
   { "call_me": name })
```

You use SexpyJSON in your Swift code with the ``SXPJParser`` and ``SXPJEvaluator`` types and the values
they return:

```swift
let input = #"{ "key": d }"#
let parser = SXPJParser()
let inputExpr = try parser.parse(source: input)
var evaluator = SXPJEvaluator()
evaluator.set(value: ["key1": "hello", "key2": ["subkey1": "world"]], for: "d")
let output = try evaluator.evaluate(expression: inputExpr)
let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])
```

## Topics

### Group


