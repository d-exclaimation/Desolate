//
//  Nozzle+Desolate.swift
//  Desolate
//
//  Created by d-exclaimation on 4:21 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Nozzle {
    /// Pipe the value of this AsyncSequence into an Actor
    ///
    /// - Parameters:
    ///   - actorRef: Actor
    ///   - onComplete: Message given on completion
    ///   - onFailure: Message given on any failure
    /// - Returns: A Task for consuming async sequence
    public func pipeTo<ActorType: AbstractDesolate>(
        actorRef: Desolate<ActorType>,
        onComplete: @escaping () -> ActorType.MessageType,
        onFailure: @escaping (Error) -> ActorType.MessageType
    ) -> Deferred<Void> where ActorType.MessageType == Element {
        actorRef.pipeAsyncSequence(self, onComplete: onComplete, onFailure: onFailure)
    }
}