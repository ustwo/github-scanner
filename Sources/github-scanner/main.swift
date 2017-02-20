//
//  main.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Commandant
import Dispatch
import GitHubScannerKit


DispatchQueue.global().async {
    let registry = CommandRegistry<GitHubScannerError>()

    registry.register(ScanCommand())
    registry.register(VersionCommand())

    let helpCommand = HelpCommand(registry: registry)

    registry.register(helpCommand)

    registry.main(defaultVerb: helpCommand.verb) { error in
        print(String(describing: error))
    }
}

dispatchMain()
