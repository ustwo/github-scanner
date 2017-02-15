//
//  RepositoriesAPITests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 15/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable force_unwrapping


import Foundation
@testable import GitHubKit
import Result
import XCTest


final class RepositoriesAPITests: XCTestCase {


    static let repositories: Repositories = {
        let foo = Repository(htmlURL: URL(string: "https://foo.com")!,
                             identifier: 123,
                             name: "foo",
                             primaryLanguage: nil,
                             licenseInfo: nil)

        let bar = Repository(htmlURL: URL(string: "https://foo.com")!,
                             identifier: 123,
                             name: "bar",
                             primaryLanguage: "Swift",
                             licenseInfo: RepositoryLicenseInfo(key: "mit",
                                                                name: "MIT License",
                                                                url: URL(string: "https://baz.com")!))

        return Repositories(elements: [foo, bar])
    }()


    // MARK: - Filter PrimaryLanguage Tests

    func testFilter_PrimaryLanguage_Empty() {
        // Given
        let primaryLanguage = ""
        let expectedCount = 2

        // When
        let actualCount = RepositoriesAPI.filter(repositories: RepositoriesAPITests.repositories,
                                                 byPrimaryLanguage: primaryLanguage).count

        // Then
        XCTAssertEqual(expectedCount, actualCount)
    }

    func testFilter_PrimaryLanguage_NULL() {
        // Given
        let primaryLanguage = "NULL"
        let expectedCount = 1
        let expectedRepositoryName = "foo"

        // When
        let result = RepositoriesAPI.filter(repositories: RepositoriesAPITests.repositories,
                                            byPrimaryLanguage: primaryLanguage)
        let actualCount = result.count
        let actualRepositoryName = result.first?.name


        // Then
        XCTAssertEqual(expectedCount, actualCount)
        XCTAssertEqual(expectedRepositoryName, actualRepositoryName)
    }

    func testFilter_PrimaryLanguage_Example() {
        // Given
        let primaryLanguage = "Swift"
        let expectedCount = 1
        let expectedRepositoryName = "bar"

        // When
        let result = RepositoriesAPI.filter(repositories: RepositoriesAPITests.repositories,
                                            byPrimaryLanguage: primaryLanguage)
        let actualCount = result.count
        let actualRepositoryName = result.first?.name


        // Then
        XCTAssertEqual(expectedCount, actualCount)
        XCTAssertEqual(expectedRepositoryName, actualRepositoryName)
    }


    // MARK: - Filter License Tests

    func testFilter_License_Empty() {
        // Given
        let license = ""
        let expectedCount = 2

        // When
        let actualCount = RepositoriesAPI.filter(repositories: RepositoriesAPITests.repositories,
                                                 byLicense: license).count

        // Then
        XCTAssertEqual(expectedCount, actualCount)
    }

    func testFilter_License_NULL() {
        // Given
        let license = "NULL"
        let expectedCount = 1
        let expectedRepositoryName = "foo"

        // When
        let result = RepositoriesAPI.filter(repositories: RepositoriesAPITests.repositories,
                                            byLicense: license)
        let actualCount = result.count
        let actualRepositoryName = result.first?.name


        // Then
        XCTAssertEqual(expectedCount, actualCount)
        XCTAssertEqual(expectedRepositoryName, actualRepositoryName)
    }

    func testFilter_License_Example() {
        // Given
        let license = "MIT License"
        let expectedCount = 1
        let expectedRepositoryName = "bar"

        // When
        let result = RepositoriesAPI.filter(repositories: RepositoriesAPITests.repositories,
                                            byLicense: license)
        let actualCount = result.count
        let actualRepositoryName = result.first?.name


        // Then
        XCTAssertEqual(expectedCount, actualCount)
        XCTAssertEqual(expectedRepositoryName, actualRepositoryName)
    }

}
