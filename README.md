# SexpyJSON

![Swift build status](https://github.com/juri/SexpyJSON/actions/workflows/swift.yml/badge.svg)

SexpyJSON is a JSON templating language that allows you to embed (something that looks a lot like) Lisp in
JSON in Lisp in JSON. This implementation is in Swift.

## License

SexpyJSON is distributed under the terms of the MIT license. See LICENSE for details.

## Code of Conduct

This project is released with a Contributor Covenant Code of Conduct. By participating in this project you agree 
to abide by its terms.

## Language Documentation

You can find documentation for the language on this project's [GitHub Pages site](https://juri.github.io/SexpyJSON/).

## Introduction

The top-level element of a SexpyJSON document can be any JSON value (object, array, string, number, null) or
a s-expression. You can interleave the s-expressions and JSON objects. Any JSON value can be replaced by a
s-expression, and values inside the s-expressions can be JSON types. 

The s-expressions can contain side-effecting subexpressions (calls to functions passed in from outside,
name definitions), but must in the end return a value convertible to JSON.

### Examples

```
"hello"
```

```
10
```

```
["hello", (concat "wor" "ld")]
```

```
{
    "url": url-passed-from-outside,
    "body-parameters": (merge
        common-variables
        {
            "dp": (concat "/" section "/" (sub article "title"))
        }
    )
}
```

