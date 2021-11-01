//
//  XCTestCase+Describe.swift
//  Desolate
//
//  Created by d-exclaimation on 9:00 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import XCTest

extension XCTestCase {
    typealias Block = (XCTestExpectation) throws -> Void
    typealias ABlock = (XCTestExpectation) async throws -> Void

    /// A Unit of test scope
    func unit(_ desc: String, timeout: TimeInterval = 5.0, code block: @escaping Block) throws {
        let expectation = XCTestExpectation(description: "Desolate when conforming to AskPattern should be able to receive responses")
        try block(expectation)
        wait(for: [expectation], timeout: timeout)
    }

    /// A Unit of test asynchronous scope
    func unit(_ desc: String, timeout: TimeInterval = 5.0, async block: @escaping ABlock) async throws {
        let expectation = XCTestExpectation(description: "Desolate when conforming to AskPattern should be able to receive responses")
        try await block(expectation)
        wait(for: [expectation], timeout: timeout)
    }
}