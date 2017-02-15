//
//  ScanCommand.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//

import Commandant
import Dispatch
import Foundation
import GitHubKit
import Result
import SwiftyTextTable


typealias Repositories = ArrayFoo<Repository>
typealias RepositoryFetchCompletion = (Repositories?, String?, NetworkError?) -> Void


public enum ScanOptionsError: GitHubScannerProtocolError {
    case invalidRepositoryType(value: String)
}


public struct ScanCommand: CommandProtocol {


    // MARK: - Types

    private struct Constants {
        static let nullOption                       = "NULL"
        static let openSourceLicenseUseAcceptHeader = "application/vnd.github.drax-preview+json"
        static let repositoryTypeParameterKey       = "type"
    }


    // MARK: - Properties

    public let verb = "scan"
    public let function = "Scans the repositories."


    // MARK: - Initializers

    public init() {}


    // MARK: - Methods

    public func run(_ options: ScanOptions) -> Result<(), GitHubScannerError> {
        let url = GitHubAPI.Repositories.organizationRepositories(organization: options.organization).url

        guard let repositoryType = OrganizationRepositoriesType(rawValue: options.repositoryType) else {
            let error = ScanOptionsError.invalidRepositoryType(value: options.repositoryType)
            return .failure(GitHubScannerError.internal(error))
        }

        // Fetch

        let fetchResult = recursivelyFetchRepositories(url: url,
                                                       repositoryType: repositoryType,
                                                       oauthToken: options.oauthToken)

        var result: Repositories
        switch fetchResult {
        case .success(let fetchedRepositories):
            result = fetchedRepositories
        case .failure(let fetchError):
            return .failure(fetchError)
        }

        // Filter

        if !options.primaryLanguage.isEmpty {
            let languageFilter: (Repository) -> Bool

            if options.primaryLanguage.uppercased() == Constants.nullOption {
                languageFilter = { repository in
                    return (repository.primaryLanguage == .none)
                }
            } else {
                languageFilter = { repository in
                    guard let primaryLanguage = repository.primaryLanguage else {
                        return false
                    }

                    return primaryLanguage == options.primaryLanguage
                }
            }

            result = Repositories(elements: result.filter(languageFilter))
        }

        if !options.license.isEmpty {
            let licenseFilter: (Repository) -> Bool

            if options.license.uppercased() == Constants.nullOption {
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

                    return licenseInfo.name == options.license
                }
            }

            result = Repositories(elements: result.filter(licenseFilter))
        }

        // Sort

        result = Repositories(elements: result.sorted(by: { $0.name < $1.name }))

        // Return

        queuedPrint(result.elements.renderTextTable())

        return .success()
    }

    private func recursivelyFetchRepositories(url: URL,
                                              repositoryType: OrganizationRepositoriesType,
                                              oauthToken: String?) -> Result<Repositories, GitHubScannerError> {

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
        RequestTransformers.apiPreview.transform(request: &request,
                                                 value: Constants.openSourceLicenseUseAcceptHeader)
        RequestTransformers.addURLParameters.transform(request: &request,
                                                       value: [Constants.repositoryTypeParameterKey:
                                                               repositoryType.rawValue])

        if let oauthToken = oauthToken {
            RequestTransformers.authorize.transform(request: &request, value: oauthToken)
        }

        Clients.ephemeral.dataTask(with: request, completion: completionHandler)

        semaphore.wait()

        if let headerLink = headerLink,
            let nextURL = URL(string: headerLink) {

            let recursiveResult = recursivelyFetchRepositories(url: nextURL,
                                                               repositoryType: repositoryType,
                                                               oauthToken: oauthToken)

            switch recursiveResult {
            case .success(let fetchedRepositories):
                repositories?.elements.append(contentsOf: fetchedRepositories)
            case .failure(let fetchError):
                return .failure(GitHubScannerError.internal(fetchError))
            }
        }

        guard let result = repositories else {
            return .failure(GitHubScannerError.internal(error ?? NetworkError.unknown(error: nil)))
        }

        return .success(result)
    }

}


// MARK: - ScanOptions

public struct ScanOptions: OptionsProtocol {
    public let license: String
    public let oauthToken: String
    public let organization: String
    public let primaryLanguage: String
    public let repositoryType: String

    public static func create(_ license: String) -> (_ oauthToken: String) ->
        (_ organization: String) -> (_ primaryLanguage: String) ->
        (_ repositoryType: String) -> ScanOptions {

        return { oauthToken in {organization in { primaryLanguage in { repositoryType in
            self.init(license: license,
                      oauthToken: oauthToken,
                      organization: organization,
                      primaryLanguage: primaryLanguage,
                      repositoryType: repositoryType)
        }}}}
    }

    public static func evaluate(_ mode: CommandMode) -> Result<ScanOptions, CommandantError<GitHubScannerError>> {
        return create
            <*> mode <| Option(key: "license",
                               defaultValue: "",
                               usage: "the license type of the repositories (e.g. 'MIT License'). " +
                                      "requires authorization")
            <*> mode <| Option(key: "oauth",
                               defaultValue: "",
                               usage: "the OAuth token to use for searching repositories")
            <*> mode <| Option(key: "organization",
                               defaultValue: "",
                               usage: "the GitHub organization to filter upon")
            <*> mode <| Option(key: "primary-language",
                               defaultValue: "",
                               usage: "the primary programming language of the repository")
            <*> mode <| Option(key: "type",
                               defaultValue: "public",
                               usage: "the type of repository (\(OrganizationRepositoriesType.allValuesList)). " +
                                      "default is `public`. may require authorization")
    }
}


public enum OrganizationRepositoriesType: String {
    case all
    case forks
    case member
    case `private`
    case `public`
    case sources

    static let allValues: [OrganizationRepositoriesType] = [.all, .forks, .member, .private, .public, .sources]

    static let allValuesList: String = {
        return OrganizationRepositoriesType.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
}
