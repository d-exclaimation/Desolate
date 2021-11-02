//
// Created by Vincent on 11/1/21.
//

import Foundation

/// Inbox type Actor for one-time or one value in memory storage / cache
public actor Inbox<MessageType>: AbstractDesolate, Identifiable {
    /// Status of the inbox
    public var status: Signal = .running

    /// Inbox identifier
    public let id: UUID = UUID()

    /// Private internal state
    private var cache: MessageType? = nil

    /// Receive messages with `at-most-once` basis and ordered guarantee and store value in an internal state
    ///
    /// - Parameter msg: Message to be stored
    /// - Returns: A Behavior signal to let the Behavior handle the Actor at the current state
    public func onMessage(msg: MessageType) async -> Signal {
        cache = msg
        return .running
    }

    /// Access the internal state if available otherwise wait
    ///
    /// - Returns: The cached value
    /// - Throws: A string as error for timeout
    public func get(timeout: TimeInterval = 5.0) async throws -> MessageType {
        let start = Date()
        while true {
            if let cache = cache {
                return cache
            }
            if abs(start.timeIntervalSinceNow) > timeout {
                throw AskPatternError(timeout: timeout)
            }
        }
    }
}