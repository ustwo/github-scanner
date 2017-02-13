//
//  Print+Additions.swift
//  GitHub Scanner
//
//  Created by Aaron McTavish on 09/02/2017.
//  Copyright © 2017 ustwo Fampany Ltd. All rights reserved.
//


// Taken from: https://github.com/realm/SwiftLint

import Dispatch
import Foundation


private let outputQueue: DispatchQueue = {
    let queue = DispatchQueue(
        label: "io.ustwo.github-scanner.outputQueue",
        qos: .userInteractive,
        target: .global(qos: .userInteractive)
    )

    #if !os(Linux)
    atexit_b {
        queue.sync(flags: .barrier) {}
    }
    #endif

    return queue
}()

/**
 A thread-safe version of Swift's standard print().
 - parameter object: Object to print.
 */
public func queuedPrint<T>(_ object: T) {
    outputQueue.async {
        print(object)
    }
}

/**
 A thread-safe, newline-terminated version of fputs(..., stderr).
 - parameter string: String to print.
 */
public func queuedPrintError(_ string: String) {
    outputQueue.async {
        fflush(stdout)
        fputs(string + "\n", stderr)
    }
}
