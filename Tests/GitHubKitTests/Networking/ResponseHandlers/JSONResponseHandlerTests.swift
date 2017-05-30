//
//  JSONResponseHandlerTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 19/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping force_try

import Foundation
@testable import GitHubKit
import XCTest


final class JSONResponseHandlerTests: XCTestCase {


    // MARK: - Types

    typealias RepositoryCompletionHandler = (DecodableArray<Repository>?, String?, NetworkError?) -> Void


    // MARK: - Properties

    let handler = JSONResponseHandler()
    let defaultResponse = HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                          statusCode: 200,
                                          httpVersion: "HTTP/1.1",
                                          headerFields: [String: String]())


    // MARK: - Test Success

    func testProcessSuccess() {
        // Given
        let expectedID = 1234
        let expectedURL = URL(string: "http://foo.com")!
        let expectedName = "foo"

        let repositoryJSON: [[String: Any]] = [["id": expectedID,
                                                "html_url": expectedURL.absoluteString,
                                                "name": expectedName]]
        let repositoryData = try! JSONSerialization.data(withJSONObject: repositoryJSON)

        // When
        let completionHandler: RepositoryCompletionHandler = { repository, link, error in
            guard error == nil else {
                XCTFail("Expected no error but found error: \(error.debugDescription)")
                return
            }

            guard let repositories = repository,
                let responseRepository = repositories.first else {

                    XCTFail("Expected success repository deserialization, but found nil.")
                    return
            }

            XCTAssertEqual(expectedID,
                           responseRepository.identifier,
                           "Expected id: \(expectedID) but found \(responseRepository.identifier)")

            XCTAssertEqual(expectedURL,
                           responseRepository.htmlURL,
                           "Expected html_url: \(expectedURL.absoluteString) " +
                           "but found \(responseRepository.htmlURL.absoluteString)")

            XCTAssertEqual(expectedName,
                           responseRepository.name,
                           "Expected name: \(expectedName) but found \(responseRepository.name)")
        }

        // Then
        assertHandlerProcess(data: repositoryData,
                             response: defaultResponse,
                             error: nil,
                             completion: completionHandler)
    }


    // MARK: - Test Failure

    func testInvalidJSONFailure() {
        // Given
        let badRepositoryJSON: [[String: Any]] = [["id": 1234]]
        let badRepositoryData = try! JSONSerialization.data(withJSONObject: badRepositoryJSON)

        // When
        let completionHandler: RepositoryCompletionHandler = { repository, link, error in
            guard let responseError = error,
                case .invalidJSON = responseError else {

                    XCTFail("Expected invalidJSON but found error: \(error.debugDescription)")
                    return
            }
        }

        // Then
        assertHandlerProcess(data: badRepositoryData,
                             response: defaultResponse,
                             error: nil,
                             completion: completionHandler)
    }


    // MARK: - Convenience

    private func assertHandlerProcess(data: Data?,
                                      response: URLResponse?,
                                      error: Error?,
                                      completion: @escaping RepositoryCompletionHandler) {

        let completionExpectation = expectation(description:"completionExpectation")
        let expectationHandler: RepositoryCompletionHandler = { repository, link, error in
            defer {
                completionExpectation.fulfill()
            }

            completion(repository, link, error)
        }

        handler.process(data: data,
                        response: response,
                        error: error,
                        completion: expectationHandler)

        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(true)
    }

}
