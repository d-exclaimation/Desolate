//
//  Timer.swift
//  Desolate
//
//  Created by d-exclaimation on 3:58 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A Unsigned integer for nanoseconds
public typealias Nanoseconds = UInt64

/// A function that returns nothing
public typealias TimedTask = () -> Void

/// Timer's action can be performed
public enum Timing {
    /// Set a delayed function given the duration in nanoseconds
    case timeout(delay: Nanoseconds, fn: TimedTask)

    /// Set a repeated function given the duration in nanoseconds
    case interval(delay: Nanoseconds, fn: TimedTask)

    /// Stop the current running task
    case cancel

    /// Ignore this message
    case ignore
}

/// Timer Actor that request to a schedule an action at a later time
public actor Timer: AbstractDesolate, BaseActor, NonStop {

    private var current: Task<Timing, Error>? = nil

    public func onMessage(msg: Timing) async -> Signal {
        switch msg {
        case .timeout(delay: let delay, fn: let fn):
            if current.isSome { break }
            current = Task {
                await Task.sleep(delay)
                fn()
                return .ignore
            }
        case .interval(delay: let delay, fn: let fn):
            if current.isSome { break }
            current = Task {
                await Task.sleep(delay)
                fn()
                return .interval(delay: delay, fn: fn)
            }
        case .cancel:
            if let curr = current {
                curr.cancel()
            }
            current = .none
        case .ignore:
            break
        }

        if let current = current {
            pipeToSelf(current) { res in
                switch res {
                case .success(let action):
                    return action
                case .failure(_):
                    return .ignore
                }
            }
        }

        return same
    }

    public init() {}
}

/// Set a delayed function given the duration in nanoseconds
func setTimeout(delay: Nanoseconds, fn: @escaping TimedTask) -> Desolate<Timer> {
    let timer = Timer.new()
    timer.timeout(delay: delay, fn: fn)
    return timer
}

/// Set a delayed function given the duration in nanoseconds
func setInterval(delay: Nanoseconds, fn: @escaping TimedTask) -> Desolate<Timer> {
    let timer = Timer.new()
    timer.interval(delay: delay, fn: fn)
    return timer
}