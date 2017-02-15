//
//  APIPreviewEndpointTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping


import Foundation
@testable import GitHubKit
import XCTest


final class APIPreviewEndpointTests: XCTestCase {


    // MARK: - Tests

    func testTransform() {
        // Given
        var request = URLRequest(url: URL(string: "https://foo.com")!)
        let expectedHeaderValue = "ABC123"

        // When
        RequestTransformers.apiPreview.transform(request: &request, value: expectedHeaderValue)
        guard let actualHeaderValue = request.value(forHTTPHeaderField: "Accept") else {
            XCTFail("Missing 'Accept' HTTP Header Field.")
            return
        }

        // Then
        XCTAssertEqual(expectedHeaderValue, actualHeaderValue,
                       "Expected accept header value: \(expectedHeaderValue) " +
                       "but instead found: \(actualHeaderValue)")
    }

    func testInvalidValue() {
        // Given
        var request = URLRequest(url: URL(string: "https://foo.com")!)
        let previewHeader = true

        // When
        RequestTransformers.authorize.transform(request: &request, value: previewHeader)
        let actualHeaderValue = request.value(forHTTPHeaderField: "Accept")

        // Then
        XCTAssertNil(actualHeaderValue,
                     "Expected accept header to be nil " +
                     "but instead found: \(actualHeaderValue)")
    }

}
