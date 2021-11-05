//
//  Timer.swift
//  Desolate
//
//  Created by d-exclaimation on 3:58 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

//
// A diagram describing the Timer actor on how it handled timeout and intervals
//
// *: Do note that the Desolate to Timer actor communication is simplified in the diagram,
// and a more in depth diagram for the desolate itself can be seen in `Desolate.swift`
//
//  Timer handle user input and Task diagram:
// ┌────────────────────────────────────────────────────────────────┐
// │     ┌────────────────────────────────────────────────────────┐ │
// │     │         callback                                       │ │
// │     │                     ┌──────────────────────────────┐   │ │
// │     │                     │ Async block                  │   │ │
// │     │                     │                              │   │ │
// │     │                     │    timeout/interval/cancel   │   │ │
// │     │                     │      ┌────────────────┐      │   │ │
// │     ▼                     │      │                ▼      │   │ │
// │ ┌───────┐      ┌──────────┼──────┴──┐         ┌────────┐ │   │ │
// │ │       ├─────►│          │         │         │        │ │   │ │
// │ │ Input │      │ Desolate    Timer  │         │  Task  ├─┼───┘ │
// │ │       ├─────►│          │         │         │        │ │     │
// │ └───────┘      └──────────┼─────────┘         └────┬───┘ │     │
// │                           │      ▲                 │     │     │
// │                           │      │                 │     │     │
// │                           │      └─────────────────┘     │     │
// │                           │           interval           │     │
// │                           │                              │     │
// │                           │                              │     │
// │  Synchronous block        └──────────────────────────────┘     │
// └────────────────────────────────────────────────────────────────┘
//

/// A Desolated Timer
public typealias Hourglass = Desolate<Timer>

/// A Unsigned integer for nanoseconds
public typealias Nanoseconds = UInt64

/// Timer Actor that request to a schedule an action at a later time
public actor Timer: AbstractDesolate, BaseActor, NonStop {

    /// A function that returns nothing
    public typealias Action = () -> Void

    /// Timer's action can be performed
    public enum Timing {
        /// Set a delayed function given the duration in nanoseconds
        case timeout(delay: Nanoseconds, fn: Action)

        /// Set a repeated function given the duration in nanoseconds
        case interval(delay: Nanoseconds, fn: Action)

        /// Stop the current running task
        case cancel

        /// Ignore this message
        case ignore
    }


    private var current: Deferred<Timing>? = nil

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
@discardableResult public func setTimeout(delay: Nanoseconds, fn: @escaping Timer.Action) -> Desolate<Timer> {
    let timer = Timer.make()
    timer.timeout(delay: delay, fn: fn)
    return timer
}

/// Set a delayed function given the duration in nanoseconds
@discardableResult public func setInterval(delay: Nanoseconds, fn: @escaping Timer.Action) -> Desolate<Timer> {
    let timer = Timer.make()
    timer.interval(delay: delay, fn: fn)
    return timer
}