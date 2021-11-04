//
//  Nozzle.swift
//  Desolate
//
//  Created by d-exclaimation on 5:57 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

// A Cold toggleable stream
public struct Nozzle<Element>: Identifiable {

    public let id: UUID = UUID()

    public actor Current: AbstractDesolate, BaseActor {
        public var status: Signal = .running

        /// Temporarily storage
        private var buffer: [Element] = []

        public func onMessage(msg: Element?) async -> Signal {
            guard let msg = msg else {
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
            status != .stopped || buffer.count > 0
        }

        public init() {}
    }

    /// The desolated ``Desolate/Nozzle/Current`` actor
    internal let desolate: Desolate<Current>

    internal init(_ desolate: Desolate<Current>) {
        self.desolate = desolate
    }
}
