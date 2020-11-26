import XCTest
@testable import ReduxVM

final class ReduxVMTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ReduxVM().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
