//
//  Desolate+Delivery.swift
//  Desolate
//
//  Created by d-exclaimation on 12:26 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate {

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// - Warning: Will not timeout by itself
    ///
    /// ```swift
    /// let myActor = Desolate(of: MyActor())
    ///
    /// myActor.ask { .returnSomething(ref: $0) }
    /// ```
    ///
    /// - Parameters:
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func ask<ReturnType>(
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async -> ReturnType {
        await withCheckedContinuation { continuation in
            let continuation = ContinuationReceiver<ReturnType>(continuation: continuation)
            tell(with: fn(continuation))
        }
    }


    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func request<ReturnType>(
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) -> Deferred<ReturnType> {
        Task { await ask(with: fn) }
    }
}