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


    // MARK: - Test Validation

    func testValidity_Valid() {
        // Given
        let args = ArgumentParser(["user", "foo"])

        // Then
        assertValidity(arguments: CommandMode.arguments(args))
    }

    func testValidity_Invalid_Category() {
        // Given
        let value = "foo"
        let args = ArgumentParser([value])

        // Then
        assertValidity(arguments: CommandMode.arguments(args),
                       validity: false,
                       error: ScanOptionsError.invalidCategory(value: value))
    }

    func testValidity_Invalid_Owner() {
        // Given
        let args = ArgumentParser(["organization"])

        // Then
        assertValidity(arguments: CommandMode.arguments(args),
                       validity: false,
                       error: ScanOptionsError.missingOwner)
    }

    func testValidity_Invalid_OrganizationRepositoryType() {
        // Given
        let value = "foo"
        let args = ArgumentParser(["organization", "ustwo", "--type", value])

        // Then
        assertValidity(arguments: CommandMode.arguments(args),
                       validity: false,
                       error: ScanOptionsError.invalidRepositoryType(value: value))
    }

    func testValidity_Invalid_SelfRepositoryType() {
        // Given
        let value = "foo"
        let args = ArgumentParser(["user", "--oauth", "ABC123", "--type", value])

        // Then
        assertValidity(arguments: CommandMode.arguments(args),
                       validity: false,
                       error: ScanOptionsError.invalidRepositoryType(value: value))
    }

    func testValidity_Invalid_UserRepositoryType() {
        // Given
        let value = "foo"
        let args = ArgumentParser(["user", "ABC", "--oauth", "ABC123", "--type", value])

        // Then
        assertValidity(arguments: CommandMode.arguments(args),
                       validity: false,
                       error: ScanOptionsError.invalidRepositoryType(value: value))
    }

    func testValidity_Invalid_MissingAuthorization() {
        // Given
        let args = ArgumentParser(["user"])

        // Then
        assertValidity(arguments: CommandMode.arguments(args),
                       validity: false,
                       error: ScanOptionsError.missingAuthorization)
    }


    // MARK: - Test Initialization

    func testDefaultInit() {
        // Given
        let args = ArgumentParser(["user"])

        // Then
        assertOptions(arguments: CommandMode.arguments(args))
    }

    func testLicense() {
        // Given
        let expectedLicense = "MIT"
        let args = ArgumentParser(["user", "--license", expectedLicense])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      license: expectedLicense)
    }

    func testOauthToken() {
        // Given
        let expectedOauthToken = "ABC123"
        let args = ArgumentParser(["user", "--oauth", expectedOauthToken])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      oauthToken: expectedOauthToken)
    }

    func testOrganization() {
        // Given
        let expectedOrganization = "ustwo"
        let args = ArgumentParser(["organization", expectedOrganization])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      owner: expectedOrganization)
    }

    func testPrimaryLanguage() {
        // Given
        let expectedPrimaryLanguage = "Swift"
        let args = ArgumentParser(["user", "--primary-language", expectedPrimaryLanguage])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      primaryLanguage: expectedPrimaryLanguage)
    }

    func testRepositoryType() {
        // Given
        let expectedRepositoryType = "private"
        let args = ArgumentParser(["user", "--type", expectedRepositoryType])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      repositoryType: expectedRepositoryType)
    }

    func testUser_Self() {
        // Given
        let expectedOwner = ""
        let args = ArgumentParser(["user", expectedOwner])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      owner: expectedOwner)
    }

    func testUser_Other() {
        // Given
        let expectedOwner = "foo"
        let args = ArgumentParser(["user", expectedOwner])

        // Then
        assertOptions(arguments: CommandMode.arguments(args),
                      owner: expectedOwner)
    }


    // MARK: - Convenience

    // swiftlint:disable:next function_body_length
    private func assertOptions(arguments: CommandMode,
                               license: String = "",
                               oauthToken: String = "",
                               owner: String = "",
                               primaryLanguage: String = "",
                               repositoryType: String = "all",
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

        guard actualResult.license == license else {
            recordFailure(withDescription:  "Expected license to be: \(license) " +
                                            "but found: \(actualResult.license)",
                          inFile: file,
                          atLine: line,
                          expected: true)
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
        guard actualResult.owner == owner else {
            recordFailure(withDescription:  "Expected owner to be: \(owner) " +
                                            "but found: \(actualResult.owner)",
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

    private func assertValidity(arguments: CommandMode,
                                validity: Bool = true,
                                error: ScanOptionsError? = nil,
                                file: String = #file, line: UInt = #line) {

        // When
        let result = ScanOptions.evaluate(arguments)
        let optionEvaluation = try? result.dematerialize()
        guard let options = optionEvaluation else {
            recordFailure(withDescription: "Unable to dematerialize result.",
                          inFile: file,
                          atLine: line,
                          expected: false)
            return
        }

        let isValid = options.validateConfiguration()

        // Then
        switch isValid {
        case .success:
            XCTAssertTrue(validity,
                          "Expected configuration to be valid but was invalid.")
        case let .failure(validityError):
            XCTAssertFalse(validity,
                           "Expected configuration to be invalid but it was valid.")
            XCTAssertEqual(error, validityError,
                           "Expected error to be: \(error.debugDescription) but instead found: \(validityError).")
        }
    }

}
