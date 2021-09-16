# SexpyJSON

SexpyJSON is a JSON templating language that allows you to embed Lisp in JSON in Lisp in JSON.
This implementation is in Swift.

It might not live up to your definition of Lisp, but it looks a lot like it.

## Syntax

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
["hello", (concat "wor", "ld")]
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

