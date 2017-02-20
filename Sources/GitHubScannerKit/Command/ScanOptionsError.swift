//
//  ScanOptionsError.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 17/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation
import GitHubKit


public enum ScanOptionsError: GitHubScannerProtocolError {
    case invalidCategory(value: String)
    case invalidRepositoryType(value: String)
    case missingAuthorization
    case missingOwner
    case unknown(error: Error)
}


extension ScanOptionsError {

    public var errorDescription: String? {
        switch self {
        case let .invalidCategory(value):
            return "Invalid Category: " + value
        case let .invalidRepositoryType(value):
            return "Invalid Repository Type: " + value
        case .missingAuthorization:
            return "Missing Authorization"
        case .missingOwner:
            return "Missing Repository Owner"
        case let .unknown(error):
            if let localError = error as? LocalizedError,
                let description = localError.errorDescription {

                return "Unknown Error: " + description
            } else {
                return "Unknown Error"
            }
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidCategory:
            return "Valid categories are: \(ScanCategory.allValuesList)"
        case .missingAuthorization:
            return "Use the '--oauth' flag and supply an access token"
        case .missingOwner:
            return "Supply an owner name (organization or user) as the second argument"
        case .invalidRepositoryType, .unknown:
            return nil
        }
    }

}


extension ScanOptionsError: Equatable {

    public static func == (lhs: ScanOptionsError, rhs: ScanOptionsError) -> Bool {
        switch (lhs, rhs) {
        case (let .invalidCategory(lhsValue), let .invalidCategory(rhsValue)):
            return lhsValue == rhsValue

        case (let .invalidRepositoryType(lhsValue), let .invalidRepositoryType(rhsValue)):
            return lhsValue == rhsValue

        case (.missingAuthorization, .missingAuthorization),
             (.missingOwner, .missingOwner):

                return true

        case (let .unknown(lhsValue), let .unknown(rhsValue)):
            return lhsValue.localizedDescription == rhsValue.localizedDescription

        default:
            return false
        }
    }

}
