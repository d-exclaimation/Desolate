//
//  Timer+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 4:44 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate where ActorType == Timer {

    /// Set a delayed function given the duration in nanoseconds
    public func timeout(delay: UInt64, fn: @escaping TimedTask) {
        tell(with: .timeout(delay: delay, fn: fn))
    }

    /// Set a repeated function given the duration in nanoseconds
    public func interval(delay: UInt64, fn: @escaping TimedTask)  {
        tell(with: .interval(delay: delay, fn: fn))
    }

    /// Set a repeated function given the duration in nanoseconds
    public func cancel() {
        tell(with: .cancel)
    }
}