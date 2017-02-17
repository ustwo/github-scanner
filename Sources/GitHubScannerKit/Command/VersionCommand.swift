//
//  VersionCommand.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 17/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Commandant
import Foundation
import Result


private let version = "0.1.0"


public struct VersionCommand: CommandProtocol {


    // MARK: - Properties

    public let verb = "version"
    public let function = "display the current version of github-scanner"


    // MARK: - Initializers

    public init() {}


    // MARK: - CommandProtocol

    public func run(_ options: NoOptions<GitHubScannerError>) -> Result<(), GitHubScannerError> {
        queuedPrint(version)
        return .success()
    }
}
