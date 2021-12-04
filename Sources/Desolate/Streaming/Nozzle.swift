//
//  Nozzle.swift
//  Desolate
//
//  Created by d-exclaimation on 5:57 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

//
// Diagram for how Nozzle work and how it conforms to AsyncSequence and use Desolate to achive that
// ┌───────────────────────────────────────────────────────────────────────────────┐
// │                                                                               │
// │                                       ┌─────────────────────────────────────┐ │
// │          ,,,                          │                                     │ │
// │                                       │   Asynchronous Isolated Scope       │ │
// │           │                           │                                     │ │
// │           │                           │            ┌────────────────────┐   │ │
// │           │                           │   Incoming │                    │   │ │
// │           │                    ┌──────┴───┐    ┌─► │  Current:Desolate  │   │ │
// │           ▼                    │          │    │   │                    │   │ │
// │                                │  Nozzle  │ ───┘   └────────────────────┘   │ │
// │  for await data in ...         │          │             ▲                   │ │
// │                      ▲         └─┬──┬─┬───┘             │     │ .next       │ │
// │           │          │           │  │ │           .next │     │  (response) │ │
// │           │          └───────────┘  │ │                       ▼             │ │
// │           │        AsyncSequence    │ │         ┌────────────────►          │ │
// │           │                         │ │         ▲                │          │ │
// │           ▼                         └─┼──────── │ AsyncIterator  │          │ │
// │                                       │         │                ▼          │ │
// │          ...                          │         └◄───────────────┘          │ │
// │                                       │                                     │ │
// │                                       └─────────────────────────────────────┘ │
// │                                                                               │
// └───────────────────────────────────────────────────────────────────────────────┘


/// A Cold toggleable stream using Desolated actors
public struct Nozzle<Element>: Identifiable {

    public let id: UUID = UUID()

    /// Current flow of this Nozzle
    public actor Current: AbstractDesolate, BaseActor {
        public var status: Signal = .running

        /// Temporarily storage
        private var buffer: [Element] = []
        private var onTermination: (() -> Void)? = nil

        public func onMessage(msg: Element?) async -> Signal {
            guard let msg = msg else {
                onTermination?()
                return .stopped
            }

            buffer.append(msg)
            return .running
        }

        /// Get the next value for the Iterator
        internal func next() async -> Element? {
            // Has started and that queue is filled, that meant value given other none is given
            buffer.count > 0 ? .some(buffer.removeFirst()) : .none
        }

        internal func ongoing() async -> Bool {
            // Ongoing -> Not ended or is still filled
            status != .stopped || !buffer.isEmpty
        }

        internal func setTermination(_ fn: @escaping () -> Void) async {
            if let termination = onTermination {
                onTermination = .some {
                    termination()
                    fn()
                }
            } else {
                onTermination = .some(fn)
            }
        }

        public init() {}
    }

    /// The desolated ``Desolate/Nozzle/Current`` actor
    internal let desolate: Desolate<Current>

    internal init(_ desolate: Desolate<Current>) {
        self.desolate = desolate
    }

    /// Stop the Nozzle
    public func shutdown() {
        desolate.tell(with: nil)
    }

    /// Set on Termination callback to deallocate resources if necessary
    public func onTermination(_ fn: @escaping () -> Void) {
        Task.init {
            await desolate.innerActor.setTermination(fn)
        }
    }
}
