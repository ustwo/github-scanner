//
//  Repository.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


/// Represents a GitHub repository.
public struct Repository {


    // MARK: - Properties

    /// URL to access the GitHub page for the repository. User friendly.
    public let htmlURL: URL
    /// GitHub identifier for the repository.
    public let identifier: Int
    /// Name of the repository.
    public let name: String
    /// Primary programming language of the repository, if there is one.
    public let primaryLanguage: String?
    /// Open-source license info for the repository, if it exists.
    public let licenseInfo: RepositoryLicenseInfo?

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
        static let license = "license"
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

        var licenseInfo: RepositoryLicenseInfo?
        if let licenseJSON = jsonArray[JSONKeys.license] {
            licenseInfo = RepositoryLicenseInfo(json: licenseJSON)
        }

        self.init(htmlURL: htmlURL,
                  identifier: identifier,
                  name: name,
                  primaryLanguage: primaryLanguage,
                  licenseInfo: licenseInfo)
    }

}
