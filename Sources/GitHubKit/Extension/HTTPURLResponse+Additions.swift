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

        content.components(separatedBy: ", ").forEach { substring in
            let linkComponents = substring.components(separatedBy: ";")
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
                linkComponents.dropFirst().forEach { component in
                    if let equalIndex = component.characters.index(of: "=") {
                        let componentKey = String(component.characters[component.startIndex..<equalIndex])
                        let range = component.index(equalIndex, offsetBy: 1)..<component.endIndex
                        let value = component.characters[range]
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
