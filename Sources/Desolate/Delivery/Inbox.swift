//
// Created by Vincent on 11/1/21.
//

import Foundation

/// Inbox for one-time or one value in memory storage / cache
public actor Inbox<Value>: AbstractDesolate, NonStop {
    /// Private internal state
    private var cache: Value? = nil

    public func onMessage(msg: Value) async -> Signal {
        cache = msg
        return same
    }

    /// Access the internal state if available otherwise wait
    ///
    /// - Returns: The cached value
    /// - Throws: A string as error for timeout
    public func get() async throws -> Value {
        if let cache = cache {
            return cache
        }
        throw AskPatternError(retries: 0)
    }

    /// Access the internal state if available otherwise wait
    ///
    /// - Returns: The cached value
    /// - Throws: A string as error for timeout
    internal func acquire() throws -> Value {
        if let cache = cache {
            return cache
        }
        throw AskPatternError(retries: 0)
    }
}