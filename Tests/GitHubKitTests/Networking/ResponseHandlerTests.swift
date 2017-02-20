//
//  ResponseHandlerTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping force_try large_tuple

import Foundation
@testable import GitHubKit
import XCTest


typealias NetworkErrorAssertion = (NetworkError) -> Void


struct MockResponseHandler: ResponseHandler {

    func process<Output: JSONInitializable>(data: Data?,
                                            response: URLResponse?,
                                            error: Error?,
                                            completion: ((_ result: Output?,
                                                          _ linkHeader: String?,
                                                          _ error: NetworkError?) -> Void)?) {

        completion?(nil, nil, nil)
    }

}


final class ResponseHandlerTests: XCTestCase {


    // MARK: - Types

    typealias RepositoryCompletionHandler = (ArrayFoo<Repository>?, String?, NetworkError?) -> Void


    // MARK: - Properties

    let handler = MockResponseHandler()
    let defaultResponse = HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                          statusCode: 200,
                                          httpVersion: "HTTP/1.1",
                                          headerFields: [String: String]())


    // MARK: - Test Validation

    func testNoDataFailure() {
        // Then
        let assertion: NetworkErrorAssertion = { error in
            guard case .unknown = error else {
                XCTFail("Expected unknown but found error: \(error)")
                return
            }
        }

        assertValidationFailure(data: nil,
                                response: defaultResponse,
                                error: nil,
                                errorAssertion: assertion)
    }

    func testNoResponseFailure() {
        // Then
        let assertion: NetworkErrorAssertion = { error in
            guard case .unknown = error else {
                XCTFail("Expected unknown but found error: \(error)")
                return
            }
        }

        assertValidationFailure(data: Data(),
                                response: nil,
                                error: nil,
                                errorAssertion: assertion)
    }

    func testFailedStatusCode() {
        // Given
        let expectedStatusCode = 404
        let response = HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                       statusCode: expectedStatusCode,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: [String: String]())

        // Then
        let assertion: NetworkErrorAssertion = { error in
            guard case .failedRequest(let statusCode) = error else {
                XCTFail("Expected failedRequest but found error: \(error)")
                return
            }

            XCTAssertEqual(statusCode,
                           expectedStatusCode,
                           "Expected statusCode: \(expectedStatusCode) but found \(statusCode)")
        }

        assertValidationFailure(data: Data(),
                                response: response,
                                error: nil,
                                errorAssertion: assertion)
    }

    func testRateLimitedFailure() {
        // Given
        let response = HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                                       statusCode: 401,
                                                       httpVersion: "HTTP/1.1",
                                                       headerFields: ["X-RateLimit-Remaining": "0"])

        // Then
        let assertion: NetworkErrorAssertion = { error in
            guard case .rateLimited = error else {
                XCTFail("Expected rateLimited but found error: \(error)")
                return
            }
        }

        assertValidationFailure(data: Data(),
                                response: response,
                                error: nil,
                                errorAssertion: assertion)
    }

    func testUnauthorizedFailure() {
        // Given
        let response = HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                                       statusCode: 401,
                                                       httpVersion: "HTTP/1.1",
                                                       headerFields: [String: String]())

        // Then
        let assertion: NetworkErrorAssertion = { error in
            guard case .unauthorized = error else {
                XCTFail("Expected unauthorized but found error: \(error)")
                return
            }
        }

        assertValidationFailure(data: Data(),
                                response: response,
                                error: nil,
                                errorAssertion: assertion)
    }


    // MARK: - Convenience

    private func assertValidationFailure(data: Data?,
                                         response: URLResponse?,
                                         error: Error?,
                                         errorAssertion: @escaping NetworkErrorAssertion) {

        let assertionExpectation = expectation(description:"assertionExpectation")
        let expectationHandler: NetworkErrorAssertion = { error in
            defer {
                assertionExpectation.fulfill()
            }

            errorAssertion(error)
        }

        // When
        let validationResult = MockResponseHandler.validateResponse(data: data,
                                                                    response: response,
                                                                    error: error)

        // Then
        switch validationResult {
        case .success:
            XCTFail("Expected validation to fail, but succeeded.")
        case let .failure(validationError):
            expectationHandler(validationError)
        }

        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(true)
    }

}
