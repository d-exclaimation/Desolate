//
//  Receiver.swift
//  Desolate
//
//  Created by d-exclaimation on 12:43 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

///
// A diagram showing receiver pattern how perform returning values with callbacks between actors:
// ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │  Synchronous block                                                                                    │
// │                                                      5. Actor respond with a "message" using receiver │
// │                6. Receiver       ┌───────────────────────────────────────────────────────────┐        │
// │                   give back      ▼                                                           │        │
// │                   to actor ┌──────────┐                                                      │        │
// │   ┌───────────────────┐ ┌──┤ Receiver │ ──────┐ 3. Give receiver     ┌───────────────────────┼───┐    │
// │   │                   │ │  └──────────┘       │    as "message"      │                       │   │    │
// │   │  ....  ◄─┐        │ │     ▲ 2. Receiver   │    to Desolate       │   Isolation (async)   │   │    │
// │   │          │  ┌─────┼─┘     │    made       │  ┌───────────┐       │                       │   │    │
// │   │   │      │  │     │       │               ▼  │           ▼       │                       │   │    │
// │   │   │    ┌─┴──┴─────┼───────┴──┐      ┌────────┴─┐      ┌──────────┼──────────┐            │   │    │
// │   │   │    │          │          │      │          │      │          │          │                │    │
// │   │   └───►│  Actor2    Desolate │      │  Input   │      │ Desolate    Actor1  ├───────►  ....  │    │
// │   │        │          │          │      │          │      │          │          │                │    │
// │   │        └──────────┼──────────┘      └────┬─────┘      └──────────┼──────────┘ 4. Isolated    │    │
// │   │                   │    ▲                 │                       │               process     │    │
// │   │                   │    │                 │                       │                           │    │
// │   │ Isolation (async) │    └─────────────────┘                       │                           │    │
// │   │                   │   1. Input ask for .ref                      │                           │    │
// │   └───────────────────┘                                              └───────────────────────────┘    │
// │                                                                                                       │
// └───────────────────────────────────────────────────────────────────────────────────────────────────────┘
///

/// Receiver class is any class that can given a value of a certain type with similar API to a Desolate, usually used for a request-response within Desolate used in something like `AskPattern` with `.ask`.
///
/// - Note: Receiver should not and aren't allowed to be instantiated on own its own.
/// - Attention: To make a Receiver, you are required to create a class that inherits and override all the methods
///
/// ### Making Receiver
///
/// - Using a Desolate `.ref`
/// ```
/// actor MyActor: AbstractDesolate, NonStop {
///     typealias MessageType = Int
///     ...
/// }
///
/// let actor = MyActor.new()
/// let receiver: Receiver<Int> = actor.ref
/// ```
///
/// - Inherit and Override with a custom class
/// ```
/// class MyLogger: Receiver<String> {
///     init() {}
///
///     override func tell(with msg: String) {
///         print(msg)
///     }
///     override func task(with msg: String) async {
///         print(msg)
///     }
/// }
///
/// let receiver: Receiver<String> = MyLogger()
/// ```
///
public class Receiver<ReceivedType> {
    internal init() {}

    /// Send a response message to the Actor referenced by this Receiver
    ///
    /// - Parameter msg: Message to be sent
    public func tell(with msg: ReceivedType) { }

    /// Asynchronously send a response message to the Actor referenced by this Receiver.
    ///
    /// - Parameter msg: Message to be sent:
    public func task(with msg: ReceivedType) async { }
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