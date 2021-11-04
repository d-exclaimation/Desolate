//
//  Slipstream+AsyncSequence.swift
//  Desolate
//
//  Created by d-exclaimation on 2:07 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Slipstream: AsyncSequence {
    /// Create an async iterator from this ``Desolate/Source``
    public func makeAsyncIterator() -> Iterator {
        let (queue, des) = Flow.construct()
        defer {
            desolate.tell(with: .sink(des))
            des.tell(with: .start)
        }
        return Iterator(queue)
    }

    /// Iterator implementation for this ``Desolate/Source``
    public struct Iterator: AsyncIteratorProtocol {

        /// The ``Desolate/Source/Queue`` actor itself to pull value
        private let queue: Flow

        fileprivate init(_ actor: Flow) {
            queue = actor
        }

        /// Send in the next value from the queue depending on the ``Desolate/Source/Next``
        public mutating func next() async -> Element? {
            while await queue.ongoing() {
                if let next = await queue.next() {
                    return next
                }
                await Task.sleep(5.milliseconds)
            }
            return nil
        }
    }
}