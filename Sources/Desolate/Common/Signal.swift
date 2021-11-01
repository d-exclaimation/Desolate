//
//  BehaviorSignal.swift
//  Desolate
//
//  Created by d-exclaimation on 6:01 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//
import Foundation

/// Signal indicate how operational an Actor
///
/// ```
/// enum CounterActions {
///     case increment, decrement, stop
///     case get(ref: RecipientRef<Int>)
/// }
/// actor Counter: AbstractBehavior {
///     typealias MessageType = CounterActions
///
///     var state: Int = 0
///
///     func onMessage(msg: MessageType) async -> BehaviorSignal {
///         switch msg {
///         case .increment:
///             state += 1
///             return .running
///         case .decrement:
///             state -= 1
///             return .running
///         case .get(let ref):
///             ref.tell(state)
///             return .running
///         case .stop:
///             return .stopped // -> Stop the actor
///         }
///     }
/// }
/// ```
public enum Signal: Equatable {
    /// Signal that behavior is still running
    case running

    /// Signal that behavior is going to ignore the next `count` messages
    case ignoring(count: Int)

    /// Signal that behavior has stopped
    case stopped

    /// Toggle the signal from `.running` to `.stopped` and vice-versa
    mutating func toggle() {
        if case .running = self {
            self = .stopped
            return
        }
        self = .running
    }
}