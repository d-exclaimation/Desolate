//
//  Nozzle+AsynSequence.swift
//  Desolate
//
//  Created by d-exclaimation on 6:31 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Nozzle: AsyncSequence {

    /// Create an async iterator out of Nozzle
    public func makeAsyncIterator() -> Iterator {
        Iterator(desolate.innerActor)
    }

    /// Async Iterator for the Nozzle
    public struct Iterator: AsyncIteratorProtocol {

        /// The ``Desolate/Nozzle/Current`` actor itself to pull value
        private let current: Current

        fileprivate init(_ actor: Current) {
            current = actor
        }

        /// Send in the next value from the queue.
        public mutating func next() async -> Element? {
            while await current.ongoing() {
                if let next = await current.next() {
                    return next
                }
                await Task.sleep(5.milliseconds)
            }
            return nil
        }
    }
}
