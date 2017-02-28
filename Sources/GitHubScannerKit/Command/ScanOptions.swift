//
//  ScanOptions.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 15/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Commandant
import Foundation
import GitHubKit
import Result


/// Options for the `scan` command.
public struct ScanOptions: OptionsProtocol {


    // MARK: - Properties

    // Arguments

    /// Category of repositories. Must be a `String` representation of `ScanCategory`.
    public let category: String
    /// Owner of the repositories. Default is an empty string.
    public let owner: String

    // Options
    
    /// Open-source license on which to filter repositories.
    ///  Default is an empty string, which does no filtering.
    ///  To filter for repositories with no license, use "NULL".
    public let license: String
    /// OAuth token to use for authorization.
    ///  Default is an empty string, which means the requests will not be authorized.
    public let oauthToken: String
    /// Primary programming language on which to filter repositories.
    ///  Default is an empty string, which does no filtering.
    ///  To filter for repositories with no primary language, use "NULL".
    public let primaryLanguage: String
    /// Type of repositories to filter.
    ///  Must be a `String` representation of `SelfRepositoriesType`, `UserRepositoriesType`,
    ///  or `OrganizationRepositoriesType` depending on `category` and `owner`.
    public let repositoryType: String


    // MARK: - Validate Options

    /// Validates the all of the options.
    ///
    /// - Returns: Returns a `Result` type with a void success or a `ScanOptionsError` if failure indicating the failure reason.
    public func validateConfiguration() -> Result<(), ScanOptionsError> {
        do {
            let categoryType = try validateCategory()

            try validateOwner(categoryType: categoryType)
            try validateRepositoryType(categoryType: categoryType)

            return .success()
        } catch let error as ScanOptionsError {
            return .failure(error)
        } catch {
            return .failure(ScanOptionsError.unknown(error: error))
        }
    }

    /// Validates the `category` option.
    ///
    /// - Returns: Returns a deserialized `ScanCategory` if it is a valid option.
    /// - Throws: `ScanOptionsError` if the `category` option is not valid.
    @discardableResult
    private func validateCategory() throws -> ScanCategory {
        guard let categoryType = ScanCategory(rawValue: category) else {
            throw ScanOptionsError.invalidCategory(value: category)
        }

        return categoryType
    }

    /// Validates the `owner` option.
    ///
    /// - Parameter categoryType: The `ScanCategory` type to which the owner belongs.
    /// - Throws: `ScanOptionsError` if the `owner` option is not valid.
    private func validateOwner(categoryType: ScanCategory) throws {
        switch categoryType {
        case .organization:
            guard !owner.isEmpty else {
                throw ScanOptionsError.missingOwner
            }
        case .user:
            guard !(owner.isEmpty && oauthToken.isEmpty) else {
                throw ScanOptionsError.missingAuthorization
            }
        }
    }

    /// Validates the `repositoryType` option.
    ///
    /// - Parameter categoryType: The `ScanCategory` type to which the repositories belong.
    /// - Throws: `ScanOptionsError` if the `repositoryType` option is not valid.
    private func validateRepositoryType(categoryType: ScanCategory) throws {
        switch categoryType {
        case .organization:
            try validateRepositoryType(type: OrganizationRepositoriesType.self)
        case .user:
            if owner.isEmpty {
                try validateRepositoryType(type: SelfRepositoriesType.self)
            } else {
                try validateRepositoryType(type: UserRepositoriesType.self)
            }
        }
    }

    private func validateRepositoryType<T: RawRepresentable>(type: T.Type) throws where T.RawValue == String {
        guard let _ = T(rawValue: repositoryType) else {
            throw ScanOptionsError.invalidRepositoryType(value: repositoryType)
        }
    }

    // MARK: - OptionsProtocol

    public static func create(_ license: String) -> (_ oauthToken: String) ->
        (_ primaryLanguage: String) -> (_ repositoryType: String) -> (_ category: String) ->
        (_ owner: String) -> ScanOptions {

        return { oauthToken in { primaryLanguage in { repositoryType in { category in { owner in
            self.init(category: category,
                      owner: owner,
                      license: license,
                      oauthToken: oauthToken,
                      primaryLanguage: primaryLanguage,
                      repositoryType: repositoryType)
        }}}}}
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
            <*> mode <| Option(key: "primary-language",
                               defaultValue: "",
                               usage: "the primary programming language of the repository")
            <*> mode <| Option(key: "type",
                               defaultValue: "all",
                               usage: "the type of repository. default value 'all'. may require authorization")
            <*> mode <| Argument(usage: "the category of repositories to scan \(ScanCategory.allValuesList)")
            <*> mode <| Argument(defaultValue: "",
                                 usage: "the owner of repositories to scan (e.g. organization name or username)")
    }
}


/// Category of repositories.
public enum ScanCategory: String {
    case organization
    case user

    static let allValues: [ScanCategory] = [.organization, .user]

    static let allValuesList: String = {
        return ScanCategory.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
}


/// Type of repositories to filter when searching own repositories.
public enum SelfRepositoriesType: String {
    case all
    case `private`
    case `public`

    static let allValues: [SelfRepositoriesType] = [.all, .private, .public]

    static let allValuesList: String = {
        return SelfRepositoriesType.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
}


/// Type of repositories to filter when searching a user's repositories.
public enum UserRepositoriesType: String {
    case all
    case member
    case owner

    static let allValues: [UserRepositoriesType] = [.all, .member, .owner]

    static let allValuesList: String = {
        return UserRepositoriesType.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
}


/// Type of repositories to filter when searching an organization's repositories.
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
