//
//  Errors.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//


public protocol GitHubScannerProtocolError: Error {}


public enum GitHubScannerError: GitHubScannerProtocolError {
    case `internal`(GitHubScannerProtocolError)
    case external(Error)
}
