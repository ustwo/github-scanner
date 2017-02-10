//
//  NetworkClient.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable large_tuple

import Foundation


enum NetworkError: GitHubScannerProtocolError {
    case failedRequest(status: Int)
    case invalidJSON
    case unknown(error: Error?)
}


final class NetworkClient {


    // MARK: - Properties

    let session: URLSession


    // MARK: - Initializers

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }


    // MARK: - Tasks

    func dataTask<Output: JSONInitializable>(with request: URLRequest,
                                             responseHandler: ResponseHandler = ResponseHandlers.default,
                                             completion: ((_ result: Output?,
                                                           _ linkHeader: String?,
                                                           _ error: NetworkError?) -> Void)? = nil) {

        session.dataTask(with: request) { data, response, error in
            responseHandler.process(data: data, response: response, error: error, completion: completion)
        }.resume()
    }

}
