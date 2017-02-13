//
//  Array+Additions.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2016 ustwo Fampany Ltd. All rights reserved.
//

import Foundation


// For use in Swift 4 when conditional conformances are allowed
// See: https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md

// extension Array: JSONInitializable where Element: JSONInitializable {
//
//
//    // MARK: - Initializers
//
//    public init?(json: Any) {
//        guard let jsonArray = json as? [Any] else {
//            return nil
//        }
//
//        var deserializedItems: [Element] = []
//        for item in jsonArray {
//            guard let deserializedItem = Element(json: item) else {
//                return nil
//            }
//
//            deserializedItems.append(deserializedItem)
//        }
//
//        self.init(deserializedItems)
//    }
//
// }


public struct ArrayFoo<Element: JSONInitializable>: JSONInitializable {

    public var elements: [Element] = []

    public subscript(index: Int) -> Element {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
        }
    }

    public init() {}

    public init(elements: [Element]) {
        self.elements = elements
    }

    public init?(json: Any) {
        guard let jsonArray = json as? [Any] else {
            return nil
        }

        for item in jsonArray {
            guard let deserializedItem = Element(json: item) else {
                return nil
            }

            elements.append(deserializedItem)
        }
    }

}


extension ArrayFoo: Collection {

    public var startIndex: Int { return 0 }

    public var endIndex: Int { return elements.count }

    public func index(after: Int) -> Int {
        return after + 1
    }

}
