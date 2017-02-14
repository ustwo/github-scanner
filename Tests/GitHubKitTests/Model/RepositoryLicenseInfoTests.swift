//
//  RepositoryLicenseInfoTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping


import Foundation
@testable import GitHubKit
import XCTest


final class RepositoryLicenseInfoTests: XCTestCase {


    // MARK: - Tests

    func testJSONInit_Success() {
        // Given
        let key = "mit"
        let name = "MIT License"
        let urlString = "https://api.github.com/licenses/mit"
        let json: [String: Any] = ["key": key,
                                   "name": name,
                                   "spdx_id": "MIT",
                                   "url": urlString]
        let expectedResult = RepositoryLicenseInfo(key: key,
                                                   name: name,
                                                   url: URL(string: urlString)!)

        // When
        let actualResult = RepositoryLicenseInfo(json: json)

        // Then
        XCTAssertNotNil(actualResult)
        XCTAssertEqual(expectedResult, actualResult!)
    }

    func testJSONInit_Failure() {
        // When
        let actualResult = RepositoryLicenseInfo(json: [true: false])

        // Then
        XCTAssertNil(actualResult)
    }

}
