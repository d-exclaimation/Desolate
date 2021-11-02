//
// Created by Vincent on 11/1/21.
//

import Foundation

/// Inbox type Actor for one-time or one value in memory storage / cache
public class Inbox<MessageType>: Receiver<MessageType> {
    /// Private internal state
    private var cache: MessageType? = nil

    internal override init() {}

    public override func tell(with msg: MessageType) {
        cache = msg
    }

    public override func task(with msg: MessageType) async {
       cache = msg
    }

    /// Access the internal state if available otherwise wait
    ///
    /// - Returns: The cached value
    /// - Throws: A string as error for timeout
    public func get(timeout: TimeInterval = 5.0) async throws -> MessageType {
        if let cache = cache {
                return cache
        }
        throw AskPatternError(timeout: timeout)
    }

    /// Access the internal state if available otherwise wait
    ///
    /// - Returns: The cached value
    /// - Throws: A string as error for timeout
    internal func acquire(timeout: TimeInterval = 5.0) throws -> MessageType {
        if let cache = cache {
            return cache
        }
        throw AskPatternError(timeout: timeout)
    }
}