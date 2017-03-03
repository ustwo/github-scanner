//
//  RepositoriesAPI.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 15/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Dispatch
import Foundation
import Result


public typealias Repositories = DecodableArray<Repository>
public typealias RepositoryFetchCompletion = (Repositories?, String?, NetworkError?) -> Void


/// Collection of static methods for interacting with the Repositories section of the GitHub API.
public struct RepositoriesAPI {


    // MARK: - Types

    private struct Constants {
        static let nullOption                   = "NULL"
        static let repositoryTypeParameterKey   = "type"
    }


    // MARK: - Fetch

    /// Fetches all the repositories using a given API url. It will use the next link header recursively calling itself until all repositories have been fetched.
    ///
    /// - Parameters:
    ///   - url: `URL` for the API endpoint.
    ///   - repositoryType: The 'type' parameter to encode into the url specifying the type of repositories to search for. This is endpoint specific.
    ///   - oauthToken: The OAuth token to use for authorization. Optional.
    ///   - acceptHeader: The accept header to specify which version of the API to use. Defaults to `GitHubAcceptHeaders.default`.
    /// - Returns: The result of the network request.
    ///             If successful, it returns a collection of `Repository`.
    ///             If failure, returns a `NetworkError` representing the issue encountered.
    public static func recursivelyFetchRepositories(url: URL,
                                                    repositoryType: String,
                                                    oauthToken: String?,
                                                    acceptHeader: GitHubAcceptHeaders = GitHubAcceptHeaders.default) ->
                                                    Result<Repositories, NetworkError> {

        let semaphore = DispatchSemaphore(value: 0)

        var repositories: Repositories?
        var error: NetworkError?
        var headerLink: String?

        let completionHandler: RepositoryFetchCompletion = { fetchedRepositories, link, responseError in
            defer {
                semaphore.signal()
            }

            repositories = fetchedRepositories
            error = responseError
            headerLink = link
        }

        var request = URLRequest(url: url)
        RequestTransformers.addAcceptHeader.transform(request: &request,
                                                      value: acceptHeader.rawValue)
        RequestTransformers.addURLParameters.transform(request: &request,
                                                       value: [Constants.repositoryTypeParameterKey:
                                                               repositoryType])

        if let oauthToken = oauthToken {
            RequestTransformers.authorize.transform(request: &request, value: oauthToken)
        }

        Clients.ephemeral.dataTask(with: request, completion: completionHandler)

        semaphore.wait()

        if let headerLink = headerLink,
            let nextURL = URL(string: headerLink) {

            let recursiveResult = RepositoriesAPI.recursivelyFetchRepositories(url: nextURL,
                                                                               repositoryType: repositoryType,
                                                                               oauthToken: oauthToken,
                                                                               acceptHeader: acceptHeader)

            switch recursiveResult {
            case let .success(fetchedRepositories):
                repositories?.elements.append(contentsOf: fetchedRepositories)
            case let .failure(fetchError):
                return .failure(fetchError)
            }
        }

        guard let result = repositories else {
            return .failure(error ?? NetworkError.unknown(error: nil))
        }

        return .success(result)
    }


    // MARK: - Filter

    /// Filters the repositories based on the pimrary programming language of the repository.
    ///
    /// - Parameters:
    ///   - repositories: The repositories to filter.
    ///   - primaryLanguage: The desired programming language. To filter on repositories which do not have a primary language, use "NULL".
    /// - Returns: The filtered repositories.
    public static func filter(repositories: Repositories, byPrimaryLanguage primaryLanguage: String) -> Repositories {
        guard !primaryLanguage.isEmpty else {
            return repositories
        }

        let languageFilter: (Repository) -> Bool

        if primaryLanguage.uppercased() == Constants.nullOption {
            languageFilter = { repository in
                return (repository.primaryLanguage == .none)
            }
        } else {
            languageFilter = { repository in
                guard let language = repository.primaryLanguage else {
                    return false
                }

                return language == primaryLanguage
            }
        }

        return Repositories(elements: repositories.filter(languageFilter))
    }

    /// Filters the repositories based on the license name of the repository.
    ///
    /// - Parameters:
    ///   - repositories: The repositories to filter.
    ///   - license: The desired programming language (e.g. "MIT License"). To filter on repositories which do not have an obvious license, use "NULL".
    /// - Returns: The filtered repositories.
    public static func filter(repositories: Repositories, byLicense license: String) -> Repositories {
        guard !license.isEmpty else {
            return repositories
        }

        let licenseFilter: (Repository) -> Bool

        if license.uppercased() == Constants.nullOption {
            licenseFilter = { repository in
                guard let licenseInfo = repository.licenseInfo else {
                    return true
                }

                return (licenseInfo.name == .none)
            }
        } else {
            licenseFilter = { repository in
                guard let licenseInfo = repository.licenseInfo else {
                    return false
                }

                return licenseInfo.name == license
            }
        }

        return Repositories(elements: repositories.filter(licenseFilter))
    }

}
