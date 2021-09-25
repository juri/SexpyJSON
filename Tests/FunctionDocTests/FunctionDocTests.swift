import Foundation
import FunctionDocExtractorCore
import SexpyJSON
import XCTest

/* FunctionDocTests extracts docs from functions and verifies the code samples work and return expected results. */

final class FunctionDocTests: XCTestCase {
    func test() throws {
        let docResults = try extractFunctionDocumentation()
        let docs = try docResults.map { url, result in
            (url, try result.get())
        }

        let parser = SXPJParser()
        var seenNames = [String: URL]()

        for (url, doc) in docs {
            XCTAssertNil(seenNames[doc.name], "Duplicate name '\(doc.name)' in \(url.path), already seen in \(seenNames[doc.name]!.path)")
            seenNames[doc.name] = url

            var evaluator = SXPJEvaluator()

            for part in doc.parts {
                guard case let .example(example) = part else { continue }
                let expr: SXPJParsedExpression
                let output: SXPJOutputValue
                do {
                    expr = try parser.parse(source: example.content)
                    output = try evaluator.evaluate(expression: expr)
                } catch {
                    XCTFail("Error while processing \(url.path): \(error)")
                    throw error
                }
                if let expectedReturn = example.expectedReturn {
                    let outputOb = output.outputToJSONObject()
                    switch outputOb {
                    case .none:
                        XCTAssertEqual(expectedReturn, "null", "Expected null return in \(url.path)")
                    case let .some(someOutput):
                        let expectValue = try JSONSerialization.jsonObject(
                            with: Data(expectedReturn.utf8),
                            options: [.fragmentsAllowed]
                        )

                        try assertEqual(someOutput, expectValue, url)
                    }
                }
            }
        }
    }
}

private func assertEqual(_ value: Any, _ expect: Any, _ url: URL) throws {
    switch (value, expect) {
    case let (valueArray as [Any?], expectArray as [Any?]):
        try assertEqual(valueArray.count, expectArray.count, url)
        for (vo, eo) in zip(valueArray, expectArray) {
            guard let v = vo, let e = eo else {
                XCTAssertNil(vo, "Found unexpected null in array in \(url.path)")
                XCTAssertNil(eo, "Didn't find expected null in array in \(url.path)")
                return
            }
            try assertEqual(v, e, url)
        }
    case let (valueBool as Bool, expectBool as Bool):
        XCTAssertEqual(valueBool, expectBool)
    case let (valueDouble as Double, expectDouble as Double):
        XCTAssertEqual(valueDouble, expectDouble, accuracy: 0.0001)
    case let (valueInt as Int, expectInt as Int):
        XCTAssertEqual(valueInt, expectInt)
    case let (valueString as String, expectString as String):
        XCTAssertEqual(valueString, expectString)
    default:
        XCTFail("Could not compare value \(value) to expected value \(expect) in \(url.path)")
    }
}