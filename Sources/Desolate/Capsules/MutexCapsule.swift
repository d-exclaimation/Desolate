//
//  MutexCapsule.swift
//  Desolate
//
//  Created by d-exclaimation on 1:18 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Mutex Capsule ia a thread safe wrapper around mutual exclusion
public class MutexCapsule<Value>: Receiver<Value> {
    /// Private internal state
    private var cache: Value? = nil
    private let mutex: NSConditionLock = NSConditionLock(condition: 0)

    override init() {}

    init(state: Value) {
        cache = state
    }

    public override func tell(with msg: Value) {
        mutex.lock(whenCondition: 0)
        cache = msg
        mutex.unlock(withCondition: 0)
    }

    public override func task(with msg: Value) async {
        mutex.lock(whenCondition: 0)
        cache = msg
        mutex.unlock(withCondition: 0)
    }

    /// Access the internal state if available
    ///
    /// - Returns: The cached value
    public func get() async throws -> Value {
        if let cache = cache {
            return cache
        }
        throw CollapsedBridge.idle
    }

    /// Access the internal state if available
    ///
    /// - Returns: The cached value
    internal func acquire() throws -> Value {
        if let cache = cache {
            return cache
        }
        throw CollapsedBridge.idle
    }
}
