import XCTest

import postman_providerTests

var tests = [XCTestCaseEntry]()
tests += postman_providerTests.allTests()
XCTMain(tests)