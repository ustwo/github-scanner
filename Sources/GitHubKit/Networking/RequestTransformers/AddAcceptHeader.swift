//
//  AddAcceptHeader.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


/// Adds an accept header to a `URLRequest`.
public final class AddAcceptHeader: RequestTransformer {


    // MARK: - Types

    private struct Constants {
        static let key = "Accept"
    }


    // MARK: - RequestTransformer

    /// Adds the accept header to the `URLRequest`.
    ///
    /// - Parameters:
    ///   - request: `URLRequest` to adapt.
    ///   - value: Accept header to use. Must be a `String`.
    ///
    /// - Note: If `value` is not a `String`, then no modification will take place and method will fail silently.
    public func transform(request: inout URLRequest, value: Any) {
        guard let previewHeader = value as? String else {
            return
        }

        request.addValue(previewHeader, forHTTPHeaderField: Constants.key)
    }

}
