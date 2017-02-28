//
//  ResponseHandler.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable large_tuple

import Foundation
import Result


/// Result type returned from a network validation.
///     If successful, returns a `Data` representation of the body and an `HTTPURLResponse`.
///     If failure, returns a `NetworkError` with specifics about why the response failed validation.
public typealias NetworkValidationResult = Result<(Data, HTTPURLResponse), NetworkError>


/// Collection of response handlers.
public enum ResponseHandlers {
    /// Default response handler, which deserializes JSON into a given type.
    static let `default` = JSONResponseHandler()
}


/// Type that conforms to `ResponseHandler` modifies processes data returned from a network request.
public protocol ResponseHandler {

    /// Process the data from a network request.
    ///
    /// - Parameters:
    ///   - data: `Data` returned from the network request, if any exist.
    ///   - response: The `URLResponse` returned from the network request, if any.
    ///   - error: A generic network error, if any, if there was a problem making the request.
    ///   - completion: The completion handler the return the results of the processing.
    func process<Output: JSONInitializable>(data: Data?,
                                            response: URLResponse?,
                                            error: Error?,
                                            completion: ((_ result: Output?,
                                                          _ linkHeader: String?,
                                                          _ error: NetworkError?) -> Void)?)

}


extension ResponseHandler {


    /// Checks the response's status code to ensure it is in the 200 range.
    ///
    /// - Parameter response: The `HTTPURLResponse` to validate.
    /// - Returns: Whether or not the response is valid.
    public static func isValidResponseStatus(_ response: HTTPURLResponse) -> Bool {
        return 200..<300 ~= response.statusCode
    }

    /// Checks the response to see if it failed due to rate limiting.
    ///
    /// - Parameter response: The `HTTPURLResponse` to validate.
    /// - Returns: Whether or not the response has been rate limited.
    public static func isRateLimitedResponse(_ response: HTTPURLResponse) -> Bool {
        if [401, 403].contains(response.statusCode),
            let rateLimitString = response.allHeaderFields["X-RateLimit-Remaining"] as? String,
            let rateLimit = Int(rateLimitString),
            rateLimit == 0 {

            return true
        }

        return false
    }

    /// Checks the response to see if it failed due to not having sufficient authorization on the request.
    ///
    /// - Parameter response: The `HTTPURLResponse` to validate.
    /// - Returns: Whether or not the response failed due to being unauthorized.
    ///
    /// - Note: Should check `ResponseHandler.isRateLimitedResponse(_:)` before calling this method,
    ///         as being rate limited could also return a 401 status code.
    public static func isUnauthorized(_ response: HTTPURLResponse) -> Bool {
        return response.statusCode == 401
    }

    /// Validates a network response.
    ///
    /// - Parameters:
    ///   - data: `Data` from the body of the response.
    ///   - response: `URLResponse` to validate.
    ///   - error: `Error` from making the network request.
    /// - Returns: If the validation is successful, returns the `data` unwrapped and the response
    ///             as an `HTTPURLResponse`. If the validation is unsuccessful, returns the `NetworkError`
    ///             representing the issue.
    ///
    /// - Note: Checks for a valid status code, rate limiting error, and authorization.
    public static func validateResponse(data: Data?, response: URLResponse?, error: Error?) -> NetworkValidationResult {
        guard let httpResponse = response as? HTTPURLResponse,
            let data = data else {

                return .failure(NetworkError.unknown(error: error))
        }

        guard Self.isValidResponseStatus(httpResponse) else {
            if Self.isRateLimitedResponse(httpResponse) {
                return .failure(NetworkError.rateLimited)
            } else if Self.isUnauthorized(httpResponse) {
                return .failure(NetworkError.unauthorized)
            }

            return .failure(NetworkError.failedRequest(status: httpResponse.statusCode))
        }

        return .success((data, httpResponse))
    }

}
