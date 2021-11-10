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
    ) async throws -> ReturnType {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox.ref))
        while true {
            do {
                let res = try await inbox.get()
                return res
            } catch {
                await Task.requeue()
            }
        }
    }

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// ```swift
    /// let myActor = Desolate(of: MyActor())
    ///
    /// myActor.ask(timeout: 3.0) { .returnSomething(ref: $0) }
    /// ```
    ///
    /// - Parameters:
    ///   - timeout: The duration in seconds when to stop waiting for results
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func ask<ReturnType>(
        timeout: TimeInterval,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async throws -> ReturnType {
        let start = Date()
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox.ref))
        var retries = 0
        while abs(start.timeIntervalSinceNow) < timeout {
            do {
                let res = try await inbox.get()
                return res
            } catch {
                retries += 1
                await Task.requeue()
            }
        }
        throw AskPatternError(retries: retries)
    }


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
        retry: Int,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async throws -> ReturnType {
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox.ref))
        for _ in (0...retry) {
            do {
                let res = try await inbox.get()
                return res
            } catch {
                await Task.requeue()
            }
        }
        throw AskPatternError(retries: retry)
    }

    /// The ask-pattern implements the initiator side of an asynchronous request–reply protocol.
    ///
    /// - Parameters:
    ///   - timeout: The duration in seconds when to stop waiting for results
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func query<ReturnType>(
        timeout: TimeInterval,
        using fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) async -> Result<ReturnType, Error> {
        let start = Date()
        let inbox = Inbox<ReturnType>()
        await task(with: fn(inbox.ref))
        var retries = 0
        while abs(start.timeIntervalSinceNow) < timeout {
            let res = await Task { try await inbox.get() }.result
            switch res {
            case .success(_):
                return res
            case .failure(_):
                retries += 1
                await Task.requeue()
            }
        }

        return .failure(AskPatternError(retries: retries))
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
        Task { try await ask(with: fn) }
    }

    /// The ask-pattern implements the initiator side of request–reply protocol.
    ///
    /// - Parameters:
    ///   - priority: Task priority for the returned Task
    ///   - timeout: The duration in seconds when to stop waiting for results
    ///   - fn: Function to return a Message that accepts a RecipientRef
    /// - Returns: The return type for the accepted RecipientRef from `fn`
    /// - Throws: A timeout error from the Inbox
    public func request<ReturnType>(
        priority: TaskPriority?,
        timeout: TimeInterval,
        with fn: @escaping (Receiver<ReturnType>) -> ActorType.MessageType
    ) -> Deferred<ReturnType> {
        Task.init(priority: priority) { try await ask(timeout: timeout, with: fn) }
    }
}