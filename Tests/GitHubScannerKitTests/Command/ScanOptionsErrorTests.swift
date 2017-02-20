//
//  ScanOptionsErrorTests.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 19/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation
@testable import GitHubScannerKit
import XCTest


final class ScanOptionsErrorTests: XCTestCase {


    // MARK: - Test Equatable

    func testInvalidCategory_Equal() {
        // Given
        let error = ScanOptionsError.invalidCategory(value: "Foo")

        // Then
        XCTAssertEqual(error, error)
    }

    func testInvalidRepositoryType_Equal() {
        // Given
        let error = ScanOptionsError.invalidRepositoryType(value: "Foo")

        // Then
        XCTAssertEqual(error, error)
    }

    func testMissingAuthorization_Equal() {
        // Given
        let error = ScanOptionsError.missingAuthorization

        // Then
        XCTAssertEqual(error, error)
    }

    func testMissingOwner_Equal() {
        // Given
        let error = ScanOptionsError.missingOwner

        // Then
        XCTAssertEqual(error, error)
    }

    func testUnknown_Equal() {
        // Given
        let error = ScanOptionsError.unknown(error: ScanOptionsError.missingAuthorization)

        // Then
        XCTAssertEqual(error, error)
    }

    func testInvalidCategory_NotEqual() {
        // Given
        let error = ScanOptionsError.invalidCategory(value: "Foo")
        let error2 = ScanOptionsError.invalidCategory(value: "Bar")

        // Then
        XCTAssertNotEqual(error, error2)
    }

    func testInvalidRepositoryType_NotEqual() {
        // Given
        let error = ScanOptionsError.invalidRepositoryType(value: "Foo")
        let error2 = ScanOptionsError.invalidRepositoryType(value: "Bar")

        // Then
        XCTAssertNotEqual(error, error2)
    }

    func testUnknown_NotEqual() {
        // Given
        let error = ScanOptionsError.unknown(error: ScanOptionsError.missingAuthorization)
        let error2 = ScanOptionsError.unknown(error: ScanOptionsError.missingOwner)

        // Then
        XCTAssertNotEqual(error, error2)
    }

    func testDifferentErrors_NotEqual() {
        // Given
        let error = ScanOptionsError.missingAuthorization
        let error2 = ScanOptionsError.missingOwner

        // Then
        XCTAssertNotEqual(error, error2)
    }

}
