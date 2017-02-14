//
//  RepositoryLicenseInfo.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 14/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


public struct RepositoryLicenseInfo {


    // MARK: - Properties

    public let key: String?
    public let name: String?
    public let url: URL?

}


// MARK: - JSONInitializable

extension RepositoryLicenseInfo: JSONInitializable {


    // MARK: - Types

    private struct JSONKeys {
        static let key = "key"
        static let name = "name"
        static let url = "url"
    }


    // MARK: - Initializers

    public init?(json: Any) {
        guard let jsonArray = json as? [String: Any] else {
            return nil
        }

        let key = jsonArray[JSONKeys.key] as? String
        let name = jsonArray[JSONKeys.name] as? String

        var url: URL?
        if let licenseURL = jsonArray[JSONKeys.url] as? String {
            url = URL(string: licenseURL)
        }

        self.init(key: key, name: name, url: url)
    }

}


// MARK: - Equatable

extension RepositoryLicenseInfo: Equatable {

    public static func == (lhs: RepositoryLicenseInfo, rhs: RepositoryLicenseInfo) -> Bool {
        return lhs.key == rhs.key &&
               lhs.name == rhs.name &&
               lhs.url == rhs.url
    }

}
