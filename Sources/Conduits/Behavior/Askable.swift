//
//  Askable.swift
//  Conduits
//
//  Created by d-exclaimation on 6:25 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Inbox type Actor for one-time or one value in memory storage / cache
public actor Inbox<MessageType>: AbstractBehavior, Identifiable {
    /// Status of the inbox
    public var status: BehaviorSignal = .running

    /// Inbox identifier
    public let id: UUID = UUID()

    /// Private internal state
    private var cache: MessageType? = nil

    /// Receive messages with `at-most-once` basis and ordered guarantee and store value in an internal state
    ///
    /// - Parameter msg: Message to be stored
    /// - Returns: A Behavior signal to let the Behavior handle the Actor at the current state
    public func onMessage(msg: MessageType) async -> BehaviorSignal {
        cache = msg
        return .running
    }

    /// Access the internal state if available otherwise wait
    ///
    /// - Returns: The cached value
    /// - Throws: A string as error for timeout
    internal func get(timeout: TimeInterval = 5.0) async throws -> MessageType {
        let start = Date()
        while true {
            if let cache = cache {
                return cache
            }
            if abs(start.timeIntervalSinceNow) > timeout {
                throw "Inbox `get`: Operation timed-out"
            }
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

/// Recipient inbox to be given a message
public typealias RecipientRef<ReturnType> = ActorRef<Inbox<ReturnType>>

extension ActorRef {

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func ask<ReturnType>(timeout: TimeInterval = 5.0, with fn: @escaping (RecipientRef<ReturnType>) -> ActorType.MessageType) async throws -> ReturnType {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(ActorRef<Inbox<ReturnType>>(of: inbox)))
        return try await inbox.get()
    }

    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: Timeout for the ask pattern
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    func request<ReturnType>(timeout: TimeInterval = 5.0, with fn: @escaping (RecipientRef<ReturnType>) -> ActorType.MessageType) -> Task<ReturnType, Error> {
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
    func request<ReturnType>(timeout: TimeInterval = 5.0, priority: TaskPriority?, with fn: @escaping (RecipientRef<ReturnType>) -> ActorType.MessageType) -> Task<ReturnType, Error> {
        Task.init(priority: priority) { try await ask(timeout: timeout, with: fn) }
    }
}