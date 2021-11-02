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
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func ask<ReturnType>(
        timeout: TimeInterval = 5.0,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async throws -> ReturnType {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox))
        return try await inbox.get(timeout: timeout)
    }

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func query<ReturnType>(
        timeout: TimeInterval = 5.0,
        using fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async -> Result<ReturnType, Error> {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox))
        return await Task { try await inbox.get(timeout: timeout) }.result
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
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
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
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) -> Task<ReturnType, Error> {
        Task.init(priority: priority) { try await ask(timeout: timeout, with: fn) }
    }
}