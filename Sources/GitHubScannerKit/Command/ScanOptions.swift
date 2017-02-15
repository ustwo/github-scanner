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


public enum ScanOptionsError: GitHubScannerProtocolError {
    case invalidCategory(value: String)
    case invalidRepositoryType(value: String)
    case missingAuthorization
    case missingOwner
}


extension ScanOptionsError: Equatable {

    public static func == (lhs: ScanOptionsError, rhs: ScanOptionsError) -> Bool {
        switch (lhs, rhs) {
        case (let .invalidCategory(lhsValue), let .invalidCategory(rhsValue)):
            return lhsValue == rhsValue

        case (let .invalidRepositoryType(lhsValue), let .invalidRepositoryType(rhsValue)):
            return lhsValue == rhsValue

        case (.missingAuthorization, .missingAuthorization),
             (.missingOwner, .missingOwner):

                return true

        default:
            return false
        }
    }

}


public struct ScanOptions: OptionsProtocol {


    // MARK: - Properties

    // Arguments
    public let category: String
    public let owner: String

    // Options
    public let license: String
    public let oauthToken: String
    public let primaryLanguage: String
    public let repositoryType: String


    // MARK: - Validate Options

    public func validateConfiguration() -> Result<(), ScanOptionsError> {
        guard let categoryType = ScanCategory(rawValue: category) else {
            let error = ScanOptionsError.invalidCategory(value: category)
            return .failure(error)
        }

        switch categoryType {
            case .organization:
                guard !owner.isEmpty else {
                    let error = ScanOptionsError.missingOwner
                    return .failure(error)
                }

                guard let _ = OrganizationRepositoriesType(rawValue: repositoryType) else {
                    let error = ScanOptionsError.invalidRepositoryType(value: repositoryType)
                    return .failure(error)
                }
            case .user:
                guard !(owner.isEmpty && oauthToken.isEmpty) else {
                    let error = ScanOptionsError.missingAuthorization
                    return .failure(error)
                }

                if owner.isEmpty {
                    guard let _ = SelfRepositoriesType(rawValue: repositoryType) else {
                        let error = ScanOptionsError.invalidRepositoryType(value: repositoryType)
                        return .failure(error)
                    }
                } else {
                    guard let _ = UserRepositoriesType(rawValue: repositoryType) else {
                        let error = ScanOptionsError.invalidRepositoryType(value: repositoryType)
                        return .failure(error)
                    }
                }
        }

        return .success()
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


public enum ScanCategory: String {
    case organization
    case user

    static let allValues: [ScanCategory] = [.organization, .user]

    static let allValuesList: String = {
        return ScanCategory.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
}


public enum SelfRepositoriesType: String {
    case all
    case `private`
    case `public`

    static let allValues: [SelfRepositoriesType] = [.all, .private, .public]

    static let allValuesList: String = {
        return SelfRepositoriesType.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
}


public enum UserRepositoriesType: String {
    case all
    case member
    case owner

    static let allValues: [UserRepositoriesType] = [.all, .member, .owner]

    static let allValuesList: String = {
        return UserRepositoriesType.allValues.map({ $0.rawValue }).joined(separator: ", ")
    }()
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
