//
//  TimerGroup.swift
//  Desolate
//
//  Created by d-exclaimation on 5:40 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

///
// A diagram for the TimerGroup managing multiple timer together, more info for each timer look in `Timer.swift`.
// ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                                                                                      │
// │                               ┌───────────────────────────────────────────────────────────────────┐  │
// │                               │                                                                   │  │
// │                               │   Async block                                                     │  │
// │                               │                                            timeout                │  │
// │                               │   ┌─────────────────────────────────────────────────┐             │  │
// │                               │   │                                                 │             │  │
// │                               │   │                                                 │             │  │
// │                               │   │                         interval                │             │  │
// │                               │   │    ┌─────────────────────────────────────┐      │             │  │
// │                               │   │    │                                     ▼      ▼             │  │
// │                               │   │    │                                    ┌─────────────┐       │  │
// │                               │   │    │                                    │             │       │  │
// │                               │   │    │                                    │   Timer     │       │  │
// │  ┌───────────┐     ┌──────────┼───┴────┴─┐               interval           │       #9    │       │  │
// │  │           ├────►│          │          │ ◄────────────────────────┐       │             │       │  │
// │  │   Input   │     │ Desolate    TGroup  │                          │       └───────┬─────┘       │  │
// │  │           ├────►│          │          ├───────────────────┐      │               │             │  │
// │  └───────────┘     └──────────┼──────────┘       cancel      │      │               │             │  │
// │                               │                              │      │               └─────────┐   │  │
// │                               │                              x      │                         │   │  │
// │                               │                                                               │   │  │
// │                               │   ┌─────────────┬─────────────┬─────────────┬─────────────┐   │   │  │
// │                               │   │             │             │             │             │   │   │  │
// │                               │   │   Timer     │   Timer     │   Timer     │   Timer     │   │   │  │
// │                               │   │      #1     │      #3     │      #5     │      #7     │   ▼   │  │
// │                               │   │             │             │             │             │       │  │
// │                               │   ├─────────────┼─────────────┼─────────────┼─────────────┤  ...  │  │
// │                               │   │             │             │             │             │       │  │
// │                               │   │   Timer     │   Timer     │   Timer     │   Timer     │       │  │
// │                               │   │      #2     │      #4     │      #6     │      #9     │       │  │
// │                               │   │             │             │             │             │       │  │
// │                               │   └─────────────┴─────────────┴─────────────┴─────────────┘       │  │
// │                               │                                                                   │  │
// │  Synchronous block            └───────────────────────────────────────────────────────────────────┘  │
// │                                                                                                      │
// └──────────────────────────────────────────────────────────────────────────────────────────────────────┘
///

/// Scheduling actions for the TimerGroup
public enum Scheduling {
    /// Set a delayed function given the duration in nanoseconds
    case timeout(delay: Nanoseconds, fn: TimedTask, ref: Receiver<UUID>)

    /// Set a repeated function given the duration in nanoseconds
    case interval(delay: Nanoseconds, fn: TimedTask, ref: Receiver<UUID>)

    /// Stop the running task with the ID
    case cancel(id: UUID)

    /// End the group
    case end
}

/// TimerGroup managed multiple Timers
public actor TimerGroup: AbstractDesolate, BaseActor {
    public var status: Signal = .running

    private var schedule: [UUID: Desolate<Timer>] = [:]

    public func onMessage(msg: Scheduling) async -> Signal {
        switch msg {
        case .timeout(delay: let delay, fn: let fn, ref: let ref):
            let id = UUID()
            let timer = Timer.new()

            timer.tell(with: .timeout(delay: delay, fn: fn))

            schedule[id] = timer

            ref.tell(with: id)

        case .interval(delay: let delay, fn: let fn, ref: let ref):
            let id = UUID()
            let timer = Timer.new()

            timer.tell(with: .interval(delay: delay, fn: fn))

            schedule[id] = timer

            ref.tell(with: id)

        case .cancel(id: let id):
            if let timer = schedule.removeValue(forKey: id) {
                timer.tell(with: .cancel)
            }
        case .end:
            return .stopped
        }
        return .running
    }

    public init() {}
}