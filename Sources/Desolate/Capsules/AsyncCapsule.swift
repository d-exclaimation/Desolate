//
//  Hook.swift
//  Desolate
//
//  Created by d-exclaimation on 8:41 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation



/// A Capsule actor for handling concurrent safe but blocking getter and setter
public actor AsyncCapsule<Value>: AbstractDesolate, CapsuleInterface, NonStop {
    /// Capsule Intent to handle  getter and setter
    @frozen public enum Intent {
        /// Getter
        case get(ref: Receiver<Value>)

        /// Setter
        case set(new: Value)

        /// Applier
        case apply(fn: (Value) -> Value)
    }

    private var safeState: Value

    public init(state: Value) {
        safeState = state
    }

    public func onMessage(msg: Intent) async -> Signal {
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

/// A Desolated Async Capsule that allow for concurrent-safe mutation
public typealias Pocket<Value> = Desolate<AsyncCapsule<Value>>

/// A Desolate of an AsyncCapsule is a Hook state
@available(*, deprecated, message: "Use `Pocket` instead")
public typealias Hook<Value> = Desolate<AsyncCapsule<Value>>

/// Initialized a new Pocker
///
/// ```swift
/// let myNumber = pockel { 0 }
///
/// Task.detached {
///     myNumber.set { $0 + 1 } // No data race
/// }
///
/// Task.detached {
///     myNumber.set { $0 + 1 } // No data race
/// }
///
/// Task.detached {
///     let curr = await myNumber.get() // No data race
///     print(curr)
/// }
/// ```
///
/// - Parameter fn: Function for creating the initial value
/// - Returns: a Desolated Async Capsule
public func pocket<Value>(_ fn: () -> Value) -> Pocket<Value> { Desolate(of: AsyncCapsule<Value>(state: fn())) }

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
@available(*, deprecated, message: "Use `pocket(_:` instead")
public func hook<Value>(fn: () -> Value) -> Hook<Value> { Desolate(of: AsyncCapsule<Value>(state: fn())) }
