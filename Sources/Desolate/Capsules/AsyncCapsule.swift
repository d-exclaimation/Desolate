//
//  Hook.swift
//  Desolate
//
//  Created by d-exclaimation on 8:41 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Hook Intent to handle hook getter and setter
@frozen public enum HookIntent<Value> {
    /// Getter
    case get(ref: Receiver<Value>)

    /// Setter
    case set(new: Value)

    /// Applier
    case apply(fn: (Value) -> Value)
}

/// A Capsule actor for handling concurrent safe but blocking getter and setter
public actor AsyncCapsule<Value>: AbstractDesolate, CapsuleInterface, NonStop {
    private var safeState: Value

    public init(state: Value) {
        safeState = state
    }

    public func onMessage(msg: HookIntent<Value>) async -> Signal {
        switch msg {
        case .get(ref: let ref):
            ref.tell(with: safeState)
        case .set(new: let new):
            safeState = new
        case .apply(fn: let fn):
           safeState = fn(safeState)
        }
        return same
    }
}

/// A Desolate of an AsyncCapsule is a Hook state
public typealias Hook<Value> = Desolate<AsyncCapsule<Value>>

/// Initialized a new hook
///
/// ```swift
/// let myNumber = hook { 0 }
///
/// Task.detached {
///     hook.set { $0 + 1 } // No data race
/// }
///
/// Task.detached {
///     hook.set { $0 + 1 } // No data race
/// }
///
/// Task.detached {
///     let curr = await hook.get() // No data race
///     print(curr)
/// }
/// ```
///
/// - Parameter fn: Function for creating the initial value
/// - Returns: a Desolated Async Capsule
public func hook<Value>(fn: () -> Value) -> Hook<Value> { Desolate(of: AsyncCapsule<Value>(state: fn())) }
