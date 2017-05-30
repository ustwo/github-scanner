//
//  AuthorizeRequestTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping


import Foundation
@testable import GitHubKit
import XCTest


final class AuthorizeRequestTests: XCTestCase {


    // MARK: - Tests

    func testTransform() {
        // Given
        var request = URLRequest(url: URL(string: "https://foo.com")!)
        let oauthToken = "ABC123"
        let expectedHeaderValue = "token \(oauthToken)"

        // When
        RequestTransformers.authorize.transform(request: &request, value: oauthToken)
        guard let actualHeaderValue = request.value(forHTTPHeaderField: "Authorization") else {
            XCTFail("Missing 'Authorization' HTTP Header Field.")
            return
        }

        // Then
        XCTAssertEqual(expectedHeaderValue, actualHeaderValue,
                       "Expected authorization header value: \(expectedHeaderValue) " +
                       "but instead found: \(actualHeaderValue)")
    }

    func testInvalidValue() {
        // Given
        var request = URLRequest(url: URL(string: "https://foo.com")!)
        let oauthToken = true

        // When
        RequestTransformers.authorize.transform(request: &request, value: oauthToken)
        let actualHeaderValue = request.value(forHTTPHeaderField: "Authorization")

        // Then
        XCTAssertNil(actualHeaderValue,
                     "Expected authorization header to be nil " +
                     "but instead found: \(actualHeaderValue.debugDescription)")
    }

}
