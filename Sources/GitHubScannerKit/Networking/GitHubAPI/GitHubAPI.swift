//
//  GitHubAPI.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


struct GitHubAPI {

    fileprivate static let baseURL = "https://api.github.com"


    enum Repositories {
        case organizationRepositories(organization: String)
    }

}


extension GitHubAPI.Repositories {

    var url: URL {
        guard let result = URL(string: GitHubAPI.baseURL + self.path) else {
            fatalError("Failed to create URL with path: \(self.path).")
        }

        return result
    }

    private var path: String {
        switch self {
            case .organizationRepositories(let organization):
                return "/orgs/\(organization)/repos"
        }
    }

}
