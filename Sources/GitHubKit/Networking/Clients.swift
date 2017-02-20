//
//  Clients.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


public enum Clients {
    public static let `default` = NetworkClient()
    public static let ephemeral: NetworkClient = {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        return NetworkClient(session: session)
    }()
}
