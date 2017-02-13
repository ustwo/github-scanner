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
typealias RepositoryFetchCompletionHandler = (Repositories?, String?, NetworkError?) -> Void


public struct ScanCommand: CommandProtocol {


    // MARK: - Properties

    public let verb = "scan"
    public let function = "Scans the repositories."


    // MARK: - Initializers

    public init() {}


    // MARK: - Methods

    public func run(_ options: ScanOptions) -> Result<(), GitHubScannerError> {
        let url = GitHubAPI.Repositories.organizationRepositories(organization: options.organization).url

        // Fetch

        let fetchResult = recursivelyFetchRepositories(url: url)

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

            if options.primaryLanguage.uppercased() == "NULL" {
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

        // Sort

        result = Repositories(elements: result.sorted(by: { $0.name < $1.name }))

        // Return

        queuedPrint(result.elements.renderTextTable())

        return .success()
    }

    private func recursivelyFetchRepositories(url: URL) -> Result<Repositories, GitHubScannerError> {
        let semaphore = DispatchSemaphore(value: 0)

        var repositories: Repositories?
        var error: NetworkError?
        var headerLink: String?

        let completionHandler: RepositoryFetchCompletionHandler = { fetchedRepositories, link, responseError in
            defer {
                semaphore.signal()
            }

            repositories = fetchedRepositories
            error = responseError
            headerLink = link
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields?["type"] = "public"

        Clients.default.dataTask(with: request, completion: completionHandler)

        semaphore.wait()

        if let headerLink = headerLink,
            let nextURL = URL(string: headerLink) {

            let recursiveResult = recursivelyFetchRepositories(url: nextURL)
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
    public let organization: String
    public let primaryLanguage: String

    public static func create(_ organization: String) -> (_ primaryLanguage: String) -> ScanOptions {
        return { primaryLanguage in
            self.init(organization: organization, primaryLanguage: primaryLanguage)
        }
    }

    public static func evaluate(_ mode: CommandMode) -> Result<ScanOptions, CommandantError<GitHubScannerError>> {
        return create
            <*> mode <| Option(key: "organization",
                               defaultValue: "",
                               usage: "the GitHub organization to filter upon")
            <*> mode <| Option(key: "primary-language",
                               defaultValue: "",
                               usage: "the primary programming language of the repository")
    }
}
