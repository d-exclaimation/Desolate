//
//  Desolate.swift
//  Desolate
//
//  Created by d-exclaimation on 6:01 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//
import Foundation

///
// These are diagrams showing the workflow of Desolate,
// when it comes to actor isolation in asynchronous block with synchronous or asynchronous code input
//
//  Synchronous to Asynchronous bridging workflow using Desolate:
// ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │    Synchronous block                                                                               │
// │                                                 ┌────────────────────────────────────────────────┐ │
// │                                                 │            Async block                         │ │
// │                                            ┌───────────┐                                         │ │
// │                                tell        │           │                                         │ │
// │                                ┌──────────►│   Task    │                                         │ │
// │                                │           │           │                        Actor-isolation  │ │
// │                                │           └────┬───┬──┘                                         │ │
// │ ┌───────────┐  tell    ┌───────┴──────┐         │   │                           ┌──────────────┐ │ │
// │ │  Sync     ├─────────►│              │         │   ▼                           │  Actor:      │ │ │
// │ │   code    │          │   Desolate   │         │ receive ── onMessage ────────►│   Abstract   │ │ │
// │ │    input  ├─────────►│              │         │   ▲                           │    Desolate  │ │ │
// │ └───────────┘ request  └───────┬──────┘         │   │                           └───┬──────────┘ │ │
// │       ▲                        │           ┌────┴───┴──┐         ┌───────┐          │            │ │
// │       │                        │           │           │         │       │          │            │ │
// │       │                        └──────────►│   Task    │ ◄───────┤ Inbox ├──────────┘            │ │
// │       │                        request     │           │         │       │   request(response)   │ │
// │       │                                    └┬───┬──────┘         └───────┘                       │ │
// │       │          request(response)          │   │                                                │ │
// │       └─────────────────────────────────────┘   └────────────────────────────────────────────────┘ │
// │                                                                                                    │
// │                                                                                                    │
// └────────────────────────────────────────────────────────────────────────────────────────────────────┘
//
//  Asynchronous workflow using Desolate:
// ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
// │                                                                                                    │
// │    Async block                                                                                     │
// │                                                                                                    │
// │                                 task                                                               │
// │                                 ┌─────────────────────┐                                            │
// │                                 │                     │                          Actor-isolation   │
// │                                 │                     │                                            │
// │  ┌───────────┐  task    ┌───────┴──────┐              │                          ┌──────────────┐  │
// │  │ Async     ├─────────►│              │              ▼                          │  Actor:      │  │
// │  │   code    │          │   Desolate   │           receive ── onMessage ────────►│   Abstract   │  │
// │  │     input ├─────────►│              │              ▲                          │    Desolate  │  │
// │  └───────────┘  ask     └───────┬──────┘              │                          └───┬──────────┘  │
// │         ▲                       │                 ┌───┴────┐                         │             │
// │         │                       │                 │        │                         │             │
// │         │                       └───────────────► │  Task  │ ◄───────────────────────┘             │
// │         │                       ask               │        │                  ask(response)        │
// │         │                                         └───┬────┘                                       │
// │         │            ask(response)                    │                                            │
// │         └─────────────────────────────────────────────┘                                            │
// │                                                                                                    │
// │                                                                                                    │
// │                                                                                                    │
// └────────────────────────────────────────────────────────────────────────────────────────────────────┘
///


/// Actor Desolate is a data structure that:
/// - handles dispatching actions both on an asynchronous code block or on a synchronous one
/// - wraps all capabilities giving a single data structure that can be safely and easily extended
/// - maintains actor isolation while allowing synchronous code to message an actor
public struct Desolate<ActorType> where ActorType: AbstractDesolate {
    /// inner actors of the reference
    internal var innerActor: ActorType

    public init(of ref: ActorType) {
        innerActor = ref
    }

    /// Send a message to the Actor referenced by this Desolate
    /// using `at-most-once` messaging semantics but doesn't wait for finished execution.
    ///
    /// - Parameter msg: Message to be sent
    public func tell(with msg: ActorType.MessageType) {
        Task.init { await innerActor.receive(msg) }
    }

    /// Asynchronously send a message to the Actor referenced by this Desolate using *at-most-once* messaging semantics.
    ///
    /// - Parameter msg: Message to be sent:
    public func task(with msg: ActorType.MessageType) async {
        let task = Task {
            await innerActor.receive(msg)
        }
        await task.value
    }
}
