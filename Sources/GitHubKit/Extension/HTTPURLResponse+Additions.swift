//
//  HTTPURLResponse+Additions.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 10/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


// Base on: https://github.com/JustHTTP/Just

extension HTTPURLResponse {


    // MARK: - Types

    private struct Constants {
        static let nextLinkHeader = "next"
        static let urlHeaderValue = "url"
    }


    // MARK: - Properties

    /// Parses the link headers from the `HTTPURLResponse` and returns a dictionary.
    public var links: [String: [String: String]] {
        var result = [String: [String: String]]()

        guard let content = allHeaderFields["Link"] as? String else {
            return result
        }

        content.components(separatedBy: ", ").forEach { s in
            let linkComponents = s.components(separatedBy: ";")
                .map {
                    ($0 as NSString).trimmingCharacters(in: CharacterSet.whitespaces)
                }
            // although a link without a rel is valid, there's no way to reference it.
            if linkComponents.count > 1 {
                // swiftlint:disable:next force_unwrapping
                let url = linkComponents.first!
                let start = url.characters.index(url.startIndex, offsetBy: 1)
                let end = url.characters.index(url.endIndex, offsetBy: -1)
                let urlRange = start..<end
                var link: [String: String] = ["url": String(url.characters[urlRange])]
                linkComponents.dropFirst().forEach { s in
                    if let equalIndex = s.characters.index(of: "=") {
                        let componentKey = String(s.characters[s.startIndex..<equalIndex])
                        let range = s.index(equalIndex, offsetBy: 1)..<s.endIndex
                        let value = s.characters[range]
                        if value.first == "\"" && value.last == "\"" {
                            let start = value.index(value.startIndex, offsetBy: 1)
                            let end = value.index(value.endIndex, offsetBy: -1)
                            link[componentKey] = String(value[start..<end])
                        } else {
                            link[componentKey] = String(value)
                        }
                    }
                }
                if let rel = link["rel"] {
                    result[rel] = link
                }
            }
        }

        return result
    }

    /// Returns the 'next' link header, if it exists.
    public var nextLink: String? {
        return links[Constants.nextLinkHeader]?[Constants.urlHeaderValue]
    }

}
