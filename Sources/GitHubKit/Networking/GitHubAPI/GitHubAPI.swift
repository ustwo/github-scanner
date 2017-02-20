//
//  GitHubAPI.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


public enum GitHubAcceptHeaders: String {
    case `default` = "application/vnd.github.v3+json"
    case openSourceLicenseUse = "application/vnd.github.drax-preview+json"
}


public struct GitHubAPI {

    fileprivate static let baseURL = "https://api.github.com"


    public enum Repositories {
        case organizationRepositories(organization: String)
        case userRepositories(username: String)
    }

}


extension GitHubAPI.Repositories {

    public var url: URL {
        guard let result = URL(string: GitHubAPI.baseURL + self.path) else {
            fatalError("Failed to create URL with path: \(self.path).")
        }

        return result
    }

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
