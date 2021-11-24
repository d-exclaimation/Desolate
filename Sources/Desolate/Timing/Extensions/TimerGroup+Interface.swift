//
//  TimerGroup+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 5:54 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Hourglasses where ActorType == TimerGroup {

    /// Set a delayed function given the duration in seconds and return an UUID for cancelling
    public func timeout(interval: TimeInterval, fn: @escaping Timer.Action) -> UUID {
        timeout(delay: interval.nanoseconds, fn: fn)
    }

    /// Set a repeated function given the duration in seconds and return an UUID for cancelling
    public func interval(interval: TimeInterval, fn: @escaping Timer.Action) -> UUID {
        self.interval(delay: interval.nanoseconds, fn: fn)
    }


    /// Set a delayed function given the duration in nanoseconds and return an UUID for cancelling
    public func timeout(delay: Nanoseconds, fn: @escaping Timer.Action) -> UUID {
        let res = conduit(within: 2.0) {
            try await ask { .timeout(delay: delay, fn: fn, ref: $0) }
        }

        switch res {
        case .success(let id):
            return id
        case .failure(_):
            return UUID()
        }
    }

    /// Set a repeated function given the duration in nanoseconds and return an UUID for cancelling
    public func interval(delay: Nanoseconds, fn: @escaping Timer.Action) -> UUID {
        let res = conduit(within: 2.0) {
            try await ask { .interval(delay: delay, fn: fn, ref: $0) }
        }

        switch res {
        case .success(let id):
            return id
        case .failure(_):
            return UUID()
        }
    }

    /// Cancel a timer from the UUID
    public func cancel(id: UUID) {
        tell(with: .cancel(id: id))
    }
}