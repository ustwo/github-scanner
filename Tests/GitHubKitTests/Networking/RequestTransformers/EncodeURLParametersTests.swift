//
//  EncodeURLParametersTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping


import Foundation
@testable import GitHubKit
import XCTest


final class EncodeURLParametersTests: XCTestCase {


    // MARK: - Tests

    func testTransform() {
        // Given
        let baseURL = "https://foo.com"
        var request = URLRequest(url: URL(string: baseURL)!)
        let expectedKey = "abc"
        let expectedValue = "123"
        let expectedURL = baseURL + "?" + expectedKey + "=" + expectedValue

        // When
        RequestTransformers.addURLParameters.transform(request: &request, value: [expectedKey: expectedValue])
        guard let actualURL = request.url?.absoluteString else {
            XCTFail("Missing 'url' for URLRequest.")
            return
        }

        // Then
        XCTAssertEqual(expectedURL, actualURL,
                       "Expected url: \(expectedURL) " +
                       "but instead found: \(actualURL)")
    }

    func testNoParameters() {
        // Given
        let baseURL = "https://foo.com"
        var request = URLRequest(url: URL(string: baseURL)!)
        let expectedURL = baseURL

        // When
        RequestTransformers.addURLParameters.transform(request: &request, value: [String: String]())
        guard let actualURL = request.url?.absoluteString else {
            XCTFail("Missing 'url' for URLRequest.")
            return
        }

        // Then
        XCTAssertEqual(expectedURL, actualURL,
                       "Expected url: \(expectedURL) " +
                       "but instead found: \(actualURL)")
    }

}
