//
//  Desolate+AskPattern.swift
//  Desolate
//
//  Created by d-exclaimation on 12:26 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate {

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func ask<ReturnType>(
        timeout: TimeInterval = 5.0,
        with fn: @escaping (Recipient<ReturnType>) -> ActorType.MessageType
    ) async throws -> ReturnType {
        let inbox = Inbox<ReturnType>()
        let recipient = Desolate<Inbox<ReturnType>>(of: inbox)
        await task(with: fn(recipient))
        return try await inbox.get(timeout: timeout)
    }

    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func request<ReturnType>(
        timeout: TimeInterval = 5.0,
        with fn: @escaping (Recipient<ReturnType>) -> ActorType.MessageType
    ) -> Task<ReturnType, Error> {
        Task { try await ask(timeout: timeout, with: fn) }
    }

    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - priority: Task priority for the returned Task
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func request<ReturnType>(
        timeout: TimeInterval = 5.0,
        priority: TaskPriority?,
        with fn: @escaping (Recipient<ReturnType>) -> ActorType.MessageType
    ) -> Task<ReturnType, Error> {
        Task.init(priority: priority) { try await ask(timeout: timeout, with: fn) }
    }
}