//
//  NetworkError.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 20/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


/// Errors that can be returned by the `NetworkClient`.
///
/// - failedRequest: A network response was returned with a status code not in the 200 series.
/// - invalidJSON: The JSON was unable to be serialized into the desired type.
/// - rateLimited: The response was denied due to exceeding the rate limits.
/// - unauthorized: The network request could not be completed due to not having sufficient authorization.
/// - unknown: An unknown network error occurred.
public enum NetworkError: LocalizedError {
    case failedRequest(status: Int)
    case invalidJSON
    case rateLimited
    case unauthorized
    case unknown(error: Error?)
}


extension NetworkError {


    public var errorDescription: String? {
        switch self {
        case let .failedRequest(status):
            return "Failed Request. Status Code: \(status)"
        case .invalidJSON:
            return "Invalid JSON returned from the server"
        case .rateLimited:
            return "Exceed rate limit for requests"
        case .unauthorized:
            return "Not authorized"
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
        case .rateLimited, .unauthorized:
            return "Use the '--oauth' flag and supply an access token"
        case .failedRequest, .invalidJSON, .unknown:
            return nil
        }
    }

}
