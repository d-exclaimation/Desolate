//
//  Receiver.swift
//  Desolate
//
//  Created by d-exclaimation on 12:43 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

// TODO: Add comment
public class Receiver<ReceivedType> {
    internal init() {}

    /// Send a response message to the Actor referenced by this Receiver
    ///
    /// - Parameter msg: Message to be sent
    public func tell(with msg: ReceivedType) { fatalError() }

    /// Asynchronously send a response message to the Actor referenced by this Receiver.
    ///
    /// - Parameter msg: Message to be sent:
    public func task(with msg: ReceivedType) async { fatalError() }
}

/// Receiver Wrapper for Desolate
internal class DesolateReceiver<ActorType: AbstractDesolate>: Receiver<ActorType.MessageType> {
    /// inner actors of the reference
    internal var innerActor: ActorType

    public init(of ref: ActorType) {
        innerActor = ref
    }

    /// Send a message to the Actor referenced by this Desolate
    /// using `at-most-once` messaging semantics but doesn't wait for finished execution.
    ///
    /// - Parameter msg: Message to be sent
    public override func tell(with msg: ActorType.MessageType) {
        Task.init { await innerActor.receive(msg) }
    }

    /// Asynchronously send a message to the Actor referenced by this Desolate using *at-most-once* messaging semantics.
    ///
    /// - Parameter msg: Message to be sent:
    public override func task(with msg: ActorType.MessageType) async {
        let task = Task {
            await innerActor.receive(msg)
        }
        await task.value
    }
}