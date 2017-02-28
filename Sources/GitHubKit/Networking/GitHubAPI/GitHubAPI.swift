//
//  GitHubAPI.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


/// Collection of possible GitHub API accept headers.
///
/// - `default`: The default accept header for the current, stable version of the API.
/// - openSourceLicenseUse: Accept header to access the license information of a repository.
public enum GitHubAcceptHeaders: String {
    case `default` = "application/vnd.github.v3+json"
    case openSourceLicenseUse = "application/vnd.github.drax-preview+json"
}


/// Collection of API endpoints for GitHub.
public struct GitHubAPI {

    /// Base url for all API requests.
    fileprivate static let baseURL = "https://api.github.com"


    /// Collection of API endpoints for accessing repository data.
    ///
    /// - organizationRepositories: Endpoint for fetching an organization's repositories.
    /// - userRepositories: Endpoint for fetching a user's repositories.
    public enum Repositories {
        case organizationRepositories(organization: String)
        case userRepositories(username: String)
    }

}


extension GitHubAPI.Repositories {

    /// `URL` for the endpoint.
    public var url: URL {
        guard let result = URL(string: GitHubAPI.baseURL + self.path) else {
            fatalError("Failed to create URL with path: \(self.path).")
        }

        return result
    }

    /// Path to append to the base url for the endpoint.
    private var path: String {
        switch self {
            case let .organizationRepositories(organization):
                return "/orgs/\(organization)/repos"
            case let .userRepositories(username):
                if username.isEmpty {
                    return "/user/repos"
                } else {
                    return "/users/\(username)/repos"
                }
        }
    }

}
