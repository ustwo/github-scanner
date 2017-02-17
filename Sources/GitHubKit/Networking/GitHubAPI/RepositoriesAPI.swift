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


public typealias Repositories = ArrayFoo<Repository>
public typealias RepositoryFetchCompletion = (Repositories?, String?, NetworkError?) -> Void


public struct RepositoriesAPI {


    // MARK: - Types

    private struct Constants {
        static let nullOption = "NULL"
        static let openSourceLicenseUseAcceptHeader = "application/vnd.github.drax-preview+json"
        static let repositoryTypeParameterKey       = "type"
    }


    // MARK: - Fetch

    public static func recursivelyFetchRepositories(url: URL,
                                                    needsLicense: Bool,
                                                    repositoryType: String,
                                                    oauthToken: String?) -> Result<Repositories, NetworkError> {

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

        if needsLicense {
            RequestTransformers.apiPreview.transform(request: &request,
                                                    value: Constants.openSourceLicenseUseAcceptHeader)
        }

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
                                                                               needsLicense: needsLicense,
                                                                               repositoryType: repositoryType,
                                                                               oauthToken: oauthToken)

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
