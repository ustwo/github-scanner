//
//  RequestTransformer.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


public protocol RequestTransformer {

    func transform(request: inout URLRequest, value: Any)

}


public enum RequestTransformers {
    public static let addURLParameters = EncodeURLParameters()
    public static let addAcceptHeader = AddAcceptHeader()
    public static let authorize = AuthorizeRequest()
}
