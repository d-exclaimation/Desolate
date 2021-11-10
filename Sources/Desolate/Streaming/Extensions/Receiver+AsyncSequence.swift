//
//  Receiver+AsyncSequence.swift
//  Desolate
//
//  Created by d-exclaimation on 4:35 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Receiver {
    /// Pipe back all async sequence result into this Actor behind this receiver as message to be handled concurrent safely
    ///
    /// - Parameters:
    ///   - seq: AsyncSequence with the proper message type
    ///   - onComplete: Message given after completion
    ///   - onFailure: Message given if a failure occurred
    /// - Returns: The Task used to consume the async sequence
    public func pipeAsyncSequence<StreamType: AsyncSequence>(
        _ seq: StreamType,
        onComplete: @escaping () -> ReceivedType,
        onFailure: @escaping (Error) -> ReceivedType
    ) -> Deferred<Void> where StreamType.Element == ReceivedType {
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