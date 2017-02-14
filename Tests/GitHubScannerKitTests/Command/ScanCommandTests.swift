//
//  ScanCommandTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Commandant
import Foundation
@testable import GitHubScannerKit
import Result
import XCTest


final class ScanOptionsTests: XCTestCase {


    // MARK: - Tests

    func testDefaultInit() {
        // Given
        let args = ArgumentParser([])

        // Then
        assertOptions(arguments: CommandMode.arguments(args))
    }

    func testOauthToken() {
        // Given
        let expectedOauthToken = "ABC123"
        let args = ArgumentParser(["--oauth", expectedOauthToken])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      oauthToken: expectedOauthToken)
    }

    func testOrganization() {
        // Given
        let expectedOrganization = "ustwo"
        let args = ArgumentParser(["--organization", expectedOrganization])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      organization: expectedOrganization)
    }

    func testPrimaryLanguage() {
        // Given
        let expectedPrimaryLanguage = "Swift"
        let args = ArgumentParser(["--primary-language", expectedPrimaryLanguage])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      primaryLanguage: expectedPrimaryLanguage)
    }

    func testRepositoryType() {
        // Given
        let expectedRepositoryType = "private"
        let args = ArgumentParser(["--type", expectedRepositoryType])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      repositoryType: expectedRepositoryType)
    }


    // MARK: - Convenience

    private func assertOptions(arguments: CommandMode,
                               oauthToken: String = "",
                               organization: String = "",
                               primaryLanguage: String = "",
                               repositoryType: String = "public",
                               file: String = #file, line: UInt = #line) {

        // When
        let result = ScanOptions.evaluate(arguments)
        let actual = try? result.dematerialize()

        // Then
        guard let actualResult = actual else {
            recordFailure(withDescription: "Unable to dematerialize result.",
                          inFile: file,
                          atLine: line,
                          expected: false)
            return
        }

        guard actualResult.oauthToken == oauthToken else {
            recordFailure(withDescription:  "Expected oauthToken to be: \(oauthToken) " +
                                            "but found: \(actualResult.oauthToken)",
                          inFile: file,
                          atLine: line,
                          expected: true)
            return
        }
        guard actualResult.organization == organization else {
            recordFailure(withDescription:  "Expected organization to be: \(organization) " +
                                            "but found: \(actualResult.organization)",
                          inFile: file,
                          atLine: line,
                          expected: true)
            return
        }
        guard actualResult.primaryLanguage == primaryLanguage else {
            recordFailure(withDescription:  "Expected primary language to be: \(primaryLanguage) " +
                                            "but found: \(actualResult.primaryLanguage)",
                          inFile: file,
                          atLine: line,
                          expected: true)
            return
        }
        guard actualResult.repositoryType == repositoryType else {
            recordFailure(withDescription:  "Expected repositoryType to be: \(repositoryType) " +
                                            "but found: \(actualResult.repositoryType)",
                          inFile: file,
                          atLine: line,
                          expected: true)
            return
        }
    }

}
