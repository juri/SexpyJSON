import XCTest

func assertEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    accuracy: T.Element,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) rethrows where T: Collection, T.Element: FloatingPoint {
    let c1 = try expression1()
    let c2 = try expression2()
    XCTAssertEqual(c1.count, c2.count, "Collections didn't have equal length", file: file, line: line)
    for (index, (e1, e2)) in zip(c1, c2).enumerated() {
        XCTAssertEqual(e1, e2, accuracy: accuracy, "Element pair #\(index) wasn't equal", file: file, line: line)
    }
}
