import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(postman_providerTests.allTests),
    ]
}
#endif