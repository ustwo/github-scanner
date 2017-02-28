//
//  Clients.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation


/// Collection of shared network clients.
public enum Clients {
    /// The default network client. Caches responses, credentials, and accepts cookies to disk.
    public static let `default` = NetworkClient()
    /// An ephemeral network client that only maintains a cache, credentials, and cookies in memory. These are not written to disk.
    public static let ephemeral: NetworkClient = {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        return NetworkClient(session: session)
    }()
}
