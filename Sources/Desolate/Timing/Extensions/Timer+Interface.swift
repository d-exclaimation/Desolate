//
//  Timer+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 4:44 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Hourglass where ActorType == Timer {

    /// Set a delayed function given the duration in nanoseconds
    public func timeout(delay: Nanoseconds, fn: @escaping Timer.Action) {
        tell(with: .timeout(delay: delay, fn: fn))
    }

    /// Set a repeated function given the duration in nanoseconds
    public func interval(delay: Nanoseconds, fn: @escaping Timer.Action)  {
        tell(with: .interval(delay: delay, fn: fn))
    }

    /// Cancel the timer
    public func cancel() {
        tell(with: .cancel)
    }
}