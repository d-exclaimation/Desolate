//
//  AbstractDesolate+Interface.swift
//  Desolate
//
//  Created by d-exclaimation on 11:40 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension AbstractDesolate {
    /// Receiver function for handling the current state for the behavior
    ///
    /// - Parameter msg: Given message
    internal func receive(_ msg: MessageType) async {
        switch status {
        case .running:
            status = await onMessage(msg: msg)
        case .ignoring(let count):
            let curr = count - 1
            status = curr <= 0 ? .running : .ignoring(count: curr)
        case .stopped:
            break
        }
    }

    /// Method for handling Task within a Behavior `onMessage` using the `pipe pattern`
    ///
    /// - Parameters:
    ///   - task: Task being executed / awaited
    ///   - mapTo: Mapping function to transform result into the behavior message type
    public func pipeToSelf<Success, Failure>(_ task: Task<Success, Failure>, into: @escaping (Result<Success, Failure>) -> MessageType) {
        Task {
            let res = await task.result
            await receive(into(res))
        }
    }

    /// The identity of this Actor, bound to the lifecycle of this Actor instance.
    /// An Actor with the same name that lives before or after this instance will have a different Desolate.
    ///
    /// This field is thread-safe and can be called from other threads than the ordinary actor message processing thread, such as `async` or `Task` callbacks.
    public var oneself: Desolate<Self> {
        Desolate(of: self)
    }

    /// Spawn a new Desolate actor
    ///
    /// - Parameter actor: Actor being spawned
    /// - Returns: A Desolated actor of this same type
    public func spawn<ActorType: AbstractDesolate>(_ actor: ActorType) -> Desolate<ActorType> {
        Desolate(of: actor)
    }

    /// Log a custom message into the standard output
    public func log(_ msg: CustomStringConvertible...) {
        print("[\(Date().ISO8601Format())]: \(msg.map { $0.description }.joined(separator: " "))")
    }
}