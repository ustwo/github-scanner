//
//  AuthorizeRequest.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


public final class AuthorizeRequest: RequestTransformer {


    // MARK: - Types

    private struct Constants {
        static let key = "Authorization"
        static let valueModifier = "token "
    }


    // MARK: - RequestTransformer

    /// Adds the authorization header to the `URLRequest`.
    ///
    /// - Parameters:
    ///   - request: `URLRequest` to authorize.
    ///   - value: OAuth token to use for authorization. Must be a `String`.
    ///
    /// - Note: If `value` is not a `String`, then no modification will take place and method will fail silently.
    public func transform(request: inout URLRequest, value: Any) {
        guard let oauthToken = value as? String else {
            return
        }

        request.addValue(Constants.valueModifier + oauthToken, forHTTPHeaderField: Constants.key)
    }

}
