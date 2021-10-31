//
//  Behavior.swift
//  Desolate
//
//  Created by d-exclaimation on 6:06 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Actor Reference that:
/// - handle dispatching actions both on an asynchronous code block or on a synchronous one
/// - wrapping all capabilities giving a single data structure that can be safely and easily extended
///
public struct ActorRef<ActorType: AbstractBehavior> {
    /// inner actors of the reference
    internal var innerActor: ActorType

    init(of ref: ActorType) {
        innerActor = ref
    }

    /// Send a message to the Actor referenced by this ActorRef
    /// using `at-most-once` messaging semantics but doesn't wait for finished execution.
    ///
    /// - Parameter msg: Message to be sent
    public func tell(with msg: ActorType.MessageType) {
        dispatch { await innerActor.receive(msg) }
    }

    /// Asynchronously send a message to the Actor referenced by this ActorRef using *at-most-once* messaging semantics.
    ///
    /// - Parameter msg: Message to be sent:
    public func task(with msg: ActorType.MessageType) async {
        let task = Task {
            await innerActor.receive(msg)
        }
        await task.value
    }
}