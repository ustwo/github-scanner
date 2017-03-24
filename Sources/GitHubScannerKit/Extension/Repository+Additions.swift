//
//  Repository+Additions.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 13/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


import Foundation
import GitHubKit
import SwiftyTextTable


extension Repository: TextTableRepresentable {


    static public  var columnHeaders: [String] {
        return ["Name", "URL"]
    }

    public var tableValues: [CustomStringConvertible] {
        return [name, htmlURL.absoluteString]
    }

    static public  var tableHeader: String? {
      return "Repositories"
    }

}
