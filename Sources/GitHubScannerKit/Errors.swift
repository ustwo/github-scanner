//
//  Errors.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation
import GitHubKit


/// Generic error for github-scanner.
public protocol GitHubScannerProtocolError: LocalizedError, CustomStringConvertible {}


extension GitHubScannerProtocolError {

    public var description: String {
        guard let errorDescription = errorDescription else {
            return ""
        }

        return errorDescription + ". " + (recoverySuggestion ?? "")
    }

}


/// Collection of github-scanner errors. Wraps both internal and generic external errors.
///
/// - `internal`: Wrapper for any internal error type.
/// - external: Wrapper for any external error type.
public enum GitHubScannerError: GitHubScannerProtocolError {
    case `internal`(GitHubScannerProtocolError)
    case external(Error)

    public var errorDescription: String? {
        switch self {
        case let .internal(error):
            return error.description
        case let .external(error):
            if let localError = error as? LocalizedError,
                let description = localError.errorDescription {

                return "External Error: " + description
            } else {
                return "External Error"
            }
        }
    }
}


extension NetworkError: GitHubScannerProtocolError {}
