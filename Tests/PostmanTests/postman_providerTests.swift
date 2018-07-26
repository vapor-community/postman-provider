import XCTest
@testable import postman_provider

final class postman_providerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(postman_provider().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
