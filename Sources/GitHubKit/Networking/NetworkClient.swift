//
//  NetworkClient.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable large_tuple

import Foundation


/// A client for accessing network resources.
public final class NetworkClient {


    // MARK: - Properties

    /// The session used by the client.
    let session: URLSession


    // MARK: - Initializers

    /// Creates a `NetworkClient`.
    ///
    /// - Parameter session: The session used by the client. Defaults to `URLSession.shared`.
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }


    // MARK: - Tasks

    /// Performs a data task (GET, POST, DELETE, etc.).
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to perform.
    ///   - responseHandler: The handler to process the data returned in the response.
    ///                      Defaults to `ResponseHandlers.default`.
    ///   - completion: The completion handler called after the `responseHandler`
    ///                 has finished processing. Defaults to `nil`.
    public func dataTask<Output: JSONInitializable>(with request: URLRequest,
                                                    responseHandler: ResponseHandler = ResponseHandlers.default,
                                                    completion: ((_ result: Output?,
                                                                  _ linkHeader: String?,
                                                                  _ error: NetworkError?) -> Void)? = nil) {

        session.dataTask(with: request) { data, response, error in
            responseHandler.process(data: data, response: response, error: error, completion: completion)
        }.resume()
    }

}
