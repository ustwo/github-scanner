//
//  main.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//


import Commandant
import Dispatch
import GitHubScannerKit


DispatchQueue.global().async {
    let registry = CommandRegistry<GitHubScannerError>()

    registry.register(ScanCommand())

    registry.main(defaultVerb: ScanCommand().verb) { error in
        print(String(describing: error))
    }
}

dispatchMain()
