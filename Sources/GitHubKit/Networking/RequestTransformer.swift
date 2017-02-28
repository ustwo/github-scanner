//
//  RequestTransformer.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


/// Type that conforms to `RequestTransformer` modifies `URLRequest`s in place.
public protocol RequestTransformer {

    /// Modifies a `URLRequest` in place.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to modify.
    ///   - value: The value to use during the modification.
    func transform(request: inout URLRequest, value: Any)

}


/// Collection of shared request transformers.
public enum RequestTransformers {
    /// Encodes and adds a dictionary of parameters to a URL.
    public static let addURLParameters = EncodeURLParameters()
    /// Adds an accept header to the request.
    public static let addAcceptHeader = AddAcceptHeader()
    /// Adds an authorization http header to the request.
    public static let authorize = AuthorizeRequest()
}
