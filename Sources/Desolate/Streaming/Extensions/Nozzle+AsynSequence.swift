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

        /// The ``Desolate/Nozzle/Sink`` actor itself to pull value
        private let sink: Sink

        fileprivate init(_ actor: Sink) {
            sink = actor
        }
        
        internal init(nozzle: Nozzle<Element>) {
            sink = nozzle.desolate.innerActor
        }


        /// Send in the next value from the queue.
        public mutating func next() async -> Element? {
            while await sink.ongoing() {
                if let next = await sink.next() {
                    return next
                }
                await Task.requeue()
            }
            return nil
        }
    }
}
