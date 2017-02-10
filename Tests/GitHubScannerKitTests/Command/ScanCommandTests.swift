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


    // MARK: - Convenience

    private func assertOptions(arguments: CommandMode,
                               organization: String = "",
                               primaryLanguage: String = "",
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
    }

}
