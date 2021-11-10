//
//  AbstractDesolate+AsyncSequence.swift
//  Desolate
//
//  Created by d-exclaimation on 2:59 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension AbstractDesolate {
    /// Pipe back all async sequence result into this Actor as message to be handled concurrent safely
    ///
    /// - Parameters:
    ///   - seq: AsyncSequence with the proper message type
    ///   - onComplete: Message given after completion
    ///   - onFailure: Message given if a failure occurred
    /// - Returns: The Task used to consume the async sequence
    public func pipeAsyncSequence<StreamType: AsyncSequence>(
        _ seq: StreamType,
        onComplete: @escaping () -> Self.MessageType,
        onFailure: @escaping (Error) -> Self.MessageType
    ) -> Deferred<Void> where StreamType.Element == Self.MessageType {
        Task.init {
            do {
                for try await elem in seq {
                    await oneself.task(with: elem)
                }
                await oneself.task(with: onComplete())
            } catch {
                await oneself.task(with: onFailure(error))
            }
        }
    }

    /// Pipe back all nozzle result into this Actor as message to be handled concurrent safely
    ///
    /// - Parameters:
    ///   - seq: Nozzle with the proper message type
    ///   - onComplete: Message given after completion
    ///   - onFailure: Message given if a failure occurred
    /// - Returns: The Task used to consume the async sequence
    public func pipeNozzle(_ nozzle: Nozzle<MessageType>,
        onComplete: @escaping () -> Self.MessageType,
        onFailure: @escaping (Error) -> Self.MessageType
    ) -> Deferred<Void> {
        pipeAsyncSequence(nozzle, onComplete: onComplete, onFailure: onFailure)
    }
}

extension Desolate {
    /// Pipe back all async sequence result into this Actor as message to be handled concurrent safely
    ///
    /// - Parameters:
    ///   - seq: AsyncSequence with the proper message type
    ///   - onComplete: Message given after completion
    ///   - onFailure: Message given if a failure occurred
    /// - Returns: The Task used to consume the async sequence
    public func pipeAsyncSequence<StreamType: AsyncSequence>(
        _ seq: StreamType,
        onComplete: @escaping () -> ActorType.MessageType,
        onFailure: @escaping (Error) -> ActorType.MessageType
    ) -> Deferred<Void> where StreamType.Element == ActorType.MessageType {
        Task.init {
            do {
                for try await elem in seq {
                    await task(with: elem)
                }
                await task(with: onComplete())
            } catch {
                await task(with: onFailure(error))
            }
        }
    }
}