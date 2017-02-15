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


public enum ScanOptionsError: GitHubScannerProtocolError {
    case invalidRepositoryType(value: String)
}


public struct ScanCommand: CommandProtocol {


    // MARK: - Properties

    public let verb = "scan"
    public let function = "Scans the repositories."


    // MARK: - Initializers

    public init() {}


    // MARK: - Methods

    public func run(_ options: ScanOptions) -> Result<(), GitHubScannerError> {
        guard let _ = OrganizationRepositoriesType(rawValue: options.repositoryType) else {
            let error = ScanOptionsError.invalidRepositoryType(value: options.repositoryType)
            return .failure(GitHubScannerError.internal(error))
        }

        let url = GitHubAPI.Repositories.organizationRepositories(organization: options.organization).url

        // Fetch

        let fetchResult = RepositoriesAPI.recursivelyFetchRepositories(url: url,
                                                                       repositoryType: options.repositoryType,
                                                                       oauthToken: options.oauthToken)

        var result: Repositories
        switch fetchResult {
        case let .success(fetchedRepositories):
            result = fetchedRepositories
        case let .failure(fetchError):
            return .failure(GitHubScannerError.internal(fetchError))
        }

        // Filter

        result = RepositoriesAPI.filter(repositories: result, byPrimaryLanguage: options.primaryLanguage)
        result = RepositoriesAPI.filter(repositories: result, byLicense: options.license)

        // Sort

        result = Repositories(elements: result.sorted(by: { $0.name < $1.name }))

        // Return

        queuedPrint(result.elements.renderTextTable())

        return .success()
    }

}


// MARK: - ScanOptions

public struct ScanOptions: OptionsProtocol {


    // MARK: - Properties

    // Options
    public let license: String
    public let oauthToken: String
    public let organization: String
    public let primaryLanguage: String
    public let repositoryType: String


    // MARK: - OptionsProtocol

    public static func create(_ license: String) -> (_ oauthToken: String) ->
        (_ organization: String) -> (_ primaryLanguage: String) ->
        (_ repositoryType: String) -> ScanOptions {

        return { oauthToken in { organization in { primaryLanguage in { repositoryType in
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
