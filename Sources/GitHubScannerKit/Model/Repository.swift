//
//  Repository.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


public struct Repository {


    // MARK: - Properties

    let htmlURL: URL
    let identifier: Int
    let name: String
    let primaryLanguage: String?

}


// MARK: - CustomStringConvertible

extension Repository: CustomStringConvertible {

    public var description: String {
        return name
    }

}


// MARK: - JSONInitializable

extension Repository: JSONInitializable {


    // MARK: - Types

    private struct JSONKeys {
        static let htmlURL = "html_url"
        static let identifier = "id"
        static let name = "name"
        static let primaryLanguage = "language"
    }


    // MARK: - Initializers

    public init?(json: Any) {
        guard let jsonArray = json as? [String: Any],
            let htmlString = jsonArray[JSONKeys.htmlURL] as? String,
            let htmlURL = URL(string: htmlString),
            let identifier = jsonArray[JSONKeys.identifier] as? Int,
            let name = jsonArray[JSONKeys.name] as? String else {

                return nil
        }

        let primaryLanguage = jsonArray[JSONKeys.primaryLanguage] as? String

        self.init(htmlURL: htmlURL, identifier: identifier, name: name, primaryLanguage: primaryLanguage)
    }

}
