//
//  ResponseHandler.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable large_tuple

import Foundation


protocol ResponseHandler {

    func process<Output: JSONInitializable>(data: Data?,
                                            response: URLResponse?,
                                            error: Error?,
                                            completion: ((_ result: Output?,
                                                          _ linkHeader: String?,
                                                          _ error: NetworkError?) -> Void)?)

}


enum ResponseHandlers {
    static let `default` = JSONResponseHandler()
}


final class JSONResponseHandler: ResponseHandler {

    func process<Output: JSONInitializable>(data: Data?,
                                            response: URLResponse?,
                                            error: Error?,
                                            completion: ((_ result: Output?,
                                                          _ linkHeader: String?,
                                                          _ error: NetworkError?) -> Void)?) {

        guard let httpResponse = response as? HTTPURLResponse,
            let data = data else {

                completion?(nil, nil, NetworkError.unknown(error: error))
                return
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            completion?(nil, nil, NetworkError.failedRequest(status: httpResponse.statusCode))
            return
        }

        if let json = try? JSONSerialization.jsonObject(with: data),
            let result = Output(json: json) {

            let links = httpResponse.links
            let link = links["next"]?["url"]
            completion?(result, link, nil)
            return
        }

        completion?(nil, nil, NetworkError.invalidJSON)
        return
    }

}
