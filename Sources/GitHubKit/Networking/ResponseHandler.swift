//
//  ResponseHandler.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable large_tuple

import Foundation


public protocol ResponseHandler {

    func process<Output: JSONInitializable>(data: Data?,
                                            response: URLResponse?,
                                            error: Error?,
                                            completion: ((_ result: Output?,
                                                          _ linkHeader: String?,
                                                          _ error: NetworkError?) -> Void)?)

}


public enum ResponseHandlers {
    static let `default` = JSONResponseHandler()
}
