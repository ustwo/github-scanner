//
//  HTTPURLResponseTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping line_length

import Foundation
@testable import GitHubKit
import XCTest


final class HTTPURLResponseTests: XCTestCase {


    // MARK: - Tests

    func testLinks() {
        // Given
        let expectedURL = "https://api.github.com/organizations/625384/repos?page=2"
        let response = HTTPURLResponse(url: URL(string: "http://foo.com")!,
                                       statusCode: 200,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: ["Link":
                                                      "<\(expectedURL)>; rel=\"next\", " +
                                                      "<https://api.github.com/organizations/625384/repos?page=2>; rel=\"last\""])!

        // When
        let actualURL = response.links["next"]?["url"]

        // Then
        XCTAssertEqual(expectedURL, actualURL)
    }

}
