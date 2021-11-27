//
//  ContinuationReceiver.swift
//  Desolate
//
//  Created by d-exclaimation on 1:56 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

internal class ContinuationReceiver<Value>: Receiver<Value> {
    private let continuation: CheckedContinuation<Value, Never>
    internal init(continuation: CheckedContinuation<Value, Never>) {
        self.continuation = continuation
    }

    /// Send a message to the Actor referenced by this Desolate
    /// using `at-most-once` messaging semantics but doesn't wait for finished execution.
    ///
    /// - Parameter msg: Message to be sent
    public override func tell(with msg: Value) {
        continuation.resume(returning: msg)
    }

    /// Asynchronously send a message to the Actor referenced by this Desolate using *at-most-once* messaging semantics.
    ///
    /// - Parameter msg: Message to be sent:
    public override func task(with msg: Value) async {
        continuation.resume(returning: msg)
    }
}
