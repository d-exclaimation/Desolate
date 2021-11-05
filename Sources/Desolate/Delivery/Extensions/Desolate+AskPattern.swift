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
    /// ```swift
    /// let myActor = Desolate(of: MyActor())
    ///
    /// myActor.ask(retry: 10) { .returnSomething(ref: $0) }
    /// ```
    ///
    /// - Parameters:
    ///   - retry: The amount retry trying to await for the value
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func ask<ReturnType>(
        retry: Int = 0,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async throws -> ReturnType {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox.ref))
        var retriesLeft = 1 + retry
        while retriesLeft > 0 {
            do {
                let res = try await inbox.get()
                return res
            } catch {
                retriesLeft -= 1
                await Task.requeue()
            }
        }
        throw AskPatternError(retries: retry)
    }

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// - Parameters:
    ///   - retry: The amount retry trying to await for the value
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func query<ReturnType>(
        retry: Int = 0,
        using fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async -> Result<ReturnType, Error> {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox.ref))
        var retriesLeft = 1 + retry
        while retriesLeft > 0 {
            let res = await Task { try await inbox.get() }.result
            switch res {
            case .success(_):
                return res
            case .failure(_):
                retriesLeft -= 1
                await Task.requeue()
            }
        }

        return .failure(AskPatternError(retries: retry))
    }

    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - retry: The amount retry trying to await for the value
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func request<ReturnType>(
        retry: Int = 0,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) -> Deferred<ReturnType> {
        Task { try await ask(retry: retry, with: fn) }
    }

    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - retry: The amount retry trying to await for the value
    ///   - priority: Task priority for the returned Task
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func request<ReturnType>(
        priority: TaskPriority?,
        retry: Int = 0,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) -> Deferred<ReturnType> {
        Task.init(priority: priority) { try await ask(retry: retry, with: fn) }
    }
}