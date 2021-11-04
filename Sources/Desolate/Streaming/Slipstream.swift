//
//  Source.swift
//  Desolate
//
//  Created by d-exclaimation on 9:13 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A Reactive stream implementation of cold stream using Actors
public struct Slipstream<Element> {
    /// Actor Queue to hold the data stream temporarily before pushing to iterator
    public actor Hub: AbstractDesolate, BaseActor, NonStop {
        /// All actions for the Queue
        public enum Act {
            case give(Element), complete, sink(Desolate<Flow>)
        }

        /// Temporarily storage
        private var closed: Bool = false
        private var queues: [UUID: Desolate<Flow>] = [:]

        /// Interface for Desolate
        public func onMessage(msg: Act) async -> Signal {
            guard !closed else { return same }

            switch msg {
            case .give(let message):
                for queue in queues.values {
                    await queue.task(with: .give(message))
                }
            case .complete:
                closed = true
                for queue in queues.values {
                    await queue.task(with: .complete)
                }
                queues.removeAll()
            case .sink(let queue):
                queues[queue.innerActor.id] = queue
            }
            return same
        }

        public init() {}
    }

    /// Actor Queue to hold the data stream temporarily before pushing to iterator
    public actor Flow: AbstractDesolate, BaseActor, NonStop, Identifiable {
        /// All actions for the Queue
        public enum Act {
            case give(Element), complete, start
        }

        public let id: UUID = UUID()

        /// Whether queue can start pushing data
        private var started: Bool = false
        private var ended: Bool = false

        /// Temporarily storage
        private var queue: [Element] = []

        /// Interface for Desolate
        public func onMessage(msg: Act) async -> Signal {
            switch msg {
            case .start:
                started = true
            case .give(let new):
                guard !ended else { break }
                queue.append(new)
            case .complete:
                ended = true
            }

            return same
        }

        /// Get the next value for the ``Desolate/Source/Iterator``
        internal func next() async -> Element? {
            // Has started and that queue is filled, that meant value given other none is given
            started && queue.count > 0 ? .some(queue.removeFirst()) : .none
        }

        internal func ongoing() async -> Bool {
            // Ongoing -> Not ended or is still filled
            !ended || queue.count > 0
        }

        public init() {}
    }

    /// The desolated ``Desolate/Source/Queue`` actor
    internal let desolate: Desolate<Hub> = Hub.create()

    public init() {}

}
