//
//  ResponseHandlerTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping

import Foundation
@testable import GitHubKit
import XCTest


final class JSONResponseHandlerTests: XCTestCase {


    // MARK: - Properties

    let handler = JSONResponseHandler()


    // MARK: - Test Failure

    func testFailedStatusCode() {
        // Given
        let expectedStatusCode = 404
        let completionExpectation = expectation(description:"completionExpectation")

        // When
        let completionHandler: (Repository?, String?, NetworkError?) -> Void = { repository, link, error in
            defer {
                completionExpectation.fulfill()
            }

            guard let responseError = error,
                case .failedRequest(let statusCode) = responseError else {

                    XCTFail("Expected failedRequest but found error: \(error)")
                    return
            }

            XCTAssertEqual(statusCode,
                           expectedStatusCode,
                           "Expected statusCode: \(expectedStatusCode) but found \(statusCode)")
        }

        // Then
        handler.process(data: Data(),
                        response: HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                                  statusCode: expectedStatusCode,
                                                  httpVersion: "HTTP/1.1",
                                                  headerFields: [String: String]()),
                        error: nil,
                        completion: completionHandler)

        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(true)
    }

}
