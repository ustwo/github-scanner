//
//  JSONResponseHandler.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// swiftlint:disable large_tuple


import Foundation
import Result


public final class JSONResponseHandler: ResponseHandler {


    // MARK: - ResponseHandler

    public func process<Output: JSONInitializable>(data: Data?,
                                                   response: URLResponse?,
                                                   error: Error?,
                                                   completion: ((_ result: Output?,
                                                                 _ linkHeader: String?,
                                                                 _ error: NetworkError?) -> Void)?) {

        let validationResult = JSONResponseHandler.validateResponse(data: data,
                                                                    response: response,
                                                                    error: error)

        switch validationResult {
        case let .success(body, httpResponse):
            let deserializationResult: Result<Output, NetworkError> = deserializeJSON(data: body)

            switch deserializationResult {
            case let .success(result):
                completion?(result, httpResponse.nextLink, nil)
                return

            case let .failure(deserializationError):
                completion?(nil, nil, deserializationError)
                return
            }

        case let .failure(validationError):
            completion?(nil, nil, validationError)
            return
        }
    }

    /// Deserializes the JSON into a model, if possible.
    ///
    /// - Parameter data: The JSON `Data` to deserialize.
    /// - Returns: If success, returns the deserialized model. Otherwise, returns a `NetworkError`.
    func deserializeJSON<Output: JSONInitializable>(data: Data) -> Result<Output, NetworkError> {
        guard let json = try? JSONSerialization.jsonObject(with: data),
            let result = Output(json: json) else {

            return .failure(NetworkError.invalidJSON)
        }

        return .success(result)
    }

}
