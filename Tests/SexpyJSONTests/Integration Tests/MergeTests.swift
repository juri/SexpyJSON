@testable import SexpyJSON
import XCTest

final class MergeTests: XCTestCase {
    func test() throws {
        let definition = #"""
            (define defined-ob {"dobkey1": "crane", "dobkey2": "bollard", "sharedkey": "dobval"})
        """#

        let input = #"""
        {
            "k1": (merge dict ob),
            "k2": (merge ob dict),
            "k3": (merge dict defined-ob),
            "k4": (merge defined-ob dict),
            "k5": (merge ob defined-ob),
            "k6": (merge defined-ob ob),
            "k7": (merge dict dict2 dict3)
        }
        """#

        let parser = SXPJParser()
        let definitionExpr = try parser.parse(source: definition)
        let inputExpr = try parser.parse(source: input)
        var evaluator = SXPJEvaluator()
        try evaluator.setAndPreconvert(value: ["obkey1": "camera", "obkey2": ["subkey1": "tiger"], "sharedkey": "obval"], for: "ob")
        evaluator.set(value: ["dictkey1": "plane", "dictkey2": "depth", "sharedkey": "dictval"], for: "dict")
        evaluator.set(value: ["dict2key1": "foliage", "dict2key2": "moist", "sharedkey": "dict2val"], for: "dict2")
        evaluator.set(value: ["dict3key1": "cork", "dict3key2": "wisdom", "sharedkey": "dict3val"], for: "dict3")
        try evaluator.evaluate(expression: definitionExpr)
        let output = try evaluator.evaluate(expression: inputExpr)
        let obj = try XCTUnwrap(output.outputToJSONObject() as? [String: Any])

        let v1 = try XCTUnwrap(obj["k1"] as? [String: Any])
        let v2 = try XCTUnwrap(obj["k2"] as? [String: Any])
        let v3 = try XCTUnwrap(obj["k3"] as? [String: Any])
        let v4 = try XCTUnwrap(obj["k4"] as? [String: Any])
        let v5 = try XCTUnwrap(obj["k5"] as? [String: Any])
        let v6 = try XCTUnwrap(obj["k6"] as? [String: Any])
        let v7 = try XCTUnwrap(obj["k7"] as? [String: Any])

        XCTAssertEqual(v1.count, 5)
        XCTAssertEqual(try XCTUnwrap(v1["dictkey1"] as? String), "plane")
        XCTAssertEqual(try XCTUnwrap(v1["dictkey2"] as? String), "depth")
        XCTAssertEqual(try XCTUnwrap(v1["obkey1"] as? String), "camera")
        XCTAssertEqual(try XCTUnwrap((v1["obkey2"] as? [String: Any])?["subkey1"] as? String), "tiger")
        XCTAssertEqual(try XCTUnwrap(v1["sharedkey"] as? String), "obval")

        XCTAssertEqual(v2.count, 5)
        XCTAssertEqual(try XCTUnwrap(v2["dictkey1"] as? String), "plane")
        XCTAssertEqual(try XCTUnwrap(v2["dictkey2"] as? String), "depth")
        XCTAssertEqual(try XCTUnwrap(v2["obkey1"] as? String), "camera")
        XCTAssertEqual(try XCTUnwrap((v2["obkey2"] as? [String: Any])?["subkey1"] as? String), "tiger")
        XCTAssertEqual(try XCTUnwrap(v2["sharedkey"] as? String), "dictval")

        XCTAssertEqual(v3.count, 5)
        XCTAssertEqual(try XCTUnwrap(v3["dictkey1"] as? String), "plane")
        XCTAssertEqual(try XCTUnwrap(v3["dictkey2"] as? String), "depth")
        XCTAssertEqual(try XCTUnwrap(v3["dobkey1"] as? String), "crane")
        XCTAssertEqual(try XCTUnwrap(v3["dobkey2"] as? String), "bollard")
        XCTAssertEqual(try XCTUnwrap(v3["sharedkey"] as? String), "dobval")

        XCTAssertEqual(v4.count, 5)
        XCTAssertEqual(try XCTUnwrap(v4["dictkey1"] as? String), "plane")
        XCTAssertEqual(try XCTUnwrap(v4["dictkey2"] as? String), "depth")
        XCTAssertEqual(try XCTUnwrap(v4["dobkey1"] as? String), "crane")
        XCTAssertEqual(try XCTUnwrap(v4["dobkey2"] as? String), "bollard")
        XCTAssertEqual(try XCTUnwrap(v4["sharedkey"] as? String), "dictval")

        XCTAssertEqual(v5.count, 5)
        XCTAssertEqual(try XCTUnwrap(v5["obkey1"] as? String), "camera")
        XCTAssertEqual(try XCTUnwrap((v5["obkey2"] as? [String: Any])?["subkey1"] as? String), "tiger")
        XCTAssertEqual(try XCTUnwrap(v5["dobkey1"] as? String), "crane")
        XCTAssertEqual(try XCTUnwrap(v5["dobkey2"] as? String), "bollard")
        XCTAssertEqual(try XCTUnwrap(v5["sharedkey"] as? String), "dobval")

        XCTAssertEqual(v6.count, 5)
        XCTAssertEqual(try XCTUnwrap(v6["obkey1"] as? String), "camera")
        XCTAssertEqual(try XCTUnwrap((v6["obkey2"] as? [String: Any])?["subkey1"] as? String), "tiger")
        XCTAssertEqual(try XCTUnwrap(v6["dobkey1"] as? String), "crane")
        XCTAssertEqual(try XCTUnwrap(v6["dobkey2"] as? String), "bollard")
        XCTAssertEqual(try XCTUnwrap(v6["sharedkey"] as? String), "obval")

        XCTAssertEqual(v7.count, 7)
        XCTAssertEqual(try XCTUnwrap(v7["dictkey1"] as? String), "plane")
        XCTAssertEqual(try XCTUnwrap(v7["dictkey2"] as? String), "depth")
        XCTAssertEqual(try XCTUnwrap(v7["dict2key1"] as? String), "foliage")
        XCTAssertEqual(try XCTUnwrap(v7["dict2key2"] as? String), "moist")
        XCTAssertEqual(try XCTUnwrap(v7["dict3key1"] as? String), "cork")
        XCTAssertEqual(try XCTUnwrap(v7["dict3key2"] as? String), "wisdom")
        XCTAssertEqual(try XCTUnwrap(v7["sharedkey"] as? String), "dict3val")
    }
}
