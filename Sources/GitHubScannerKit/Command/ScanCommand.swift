//
//  ScanCommand.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Commandant
import Foundation
import GitHubKit
import Result
import SwiftyTextTable


public struct ScanCommand: CommandProtocol {


    // MARK: - Properties

    public let verb = "scan"
    public let function = "Scans the repositories.\n" +
                          "usage: scan (organization|user) [<repo-owner> ]" +
                          "[--license <license-name>] [--oauth <token>] " +
                          "[--primary-language <language>] [--type <repo-type>]"

    // MARK: - Initializers

    public init() {}


    // MARK: - Methods

    public func run(_ options: ScanOptions) -> Result<(), GitHubScannerError> {
        switch options.validateConfiguration() {
        case .success:
            break
        case let .failure(error):
            return .failure(GitHubScannerError.internal(error))
        }

        // Was previously validated, thus safe to force unwrap
        // swiftlint:disable:next force_unwrapping
        let category = ScanCategory(rawValue: options.category)!

        let url: URL
        switch category {
        case .organization:
            url = GitHubAPI.Repositories.organizationRepositories(organization: options.owner).url
        case .user:
            url = GitHubAPI.Repositories.userRepositories(username: options.owner).url
        }

        // Fetch

        let needsLicense = !options.license.isEmpty
        let fetchResult = RepositoriesAPI.recursivelyFetchRepositories(url: url,
                                                                       needsLicense: needsLicense,
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
