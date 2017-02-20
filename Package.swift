//
//  Package.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 08/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "github-scanner",
    targets: [
        Target(name: "github-scanner",
            dependencies: [.Target(name: "GitHubScannerKit")]),
        Target(name: "GitHubScannerKit",
            dependencies: [.Target(name: "GitHubKit")]),
        Target(name: "GitHubKit")
    ],
    dependencies: [
        .Package(url: "https://github.com/Carthage/Commandant", majorVersion: 0),
        .Package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", majorVersion: 0, minor: 6)
    ]
)
