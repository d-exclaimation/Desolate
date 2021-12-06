//
//  Source.swift
//  Desolate
//
//  Created by d-exclaimation on 9:13 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A Hot broadcast stream implementation using Desolated actors, that can easily create multiple ``Desolate/Nozzle``
public struct Source<Element>: Sendable {
    public typealias Sink = Desolate<Nozzle<Element>.Sink>

    /// Actor to distribute to multiple Sinks
    public actor Supply: AbstractDesolate, BaseActor {
        /// All actions for the Queue
        public enum Act {
            case next(Element), complete
            case attach(id: UUID, sink: Sink), detach(id: UUID)
        }

        public var status: Signal = .running

        /// Temporarily storage
        private var sinks: [UUID: Sink] = [:]

        /// Interface for Desolate
        public func onMessage(msg: Act) async -> Signal {
            switch msg {
            case .next(let message):
                for nozzle in sinks.values {
                    await nozzle.task(with: message)
                }
            case .complete:
                for queue in sinks.values {
                    await queue.task(with: nil)
                }
                sinks.removeAll()
                return .stopped
            case .attach(let id, let nozzle):
                sinks[id] = nozzle
            case .detach(id: let id):
                sinks.removeValue(forKey: id)
            }
            return .running
        }

        public init() {}
    }

    /// The desolated ``Desolate/Source/Supply`` actor
    internal let desolate: Desolate<Supply>

    internal init(_ engine: Desolate<Supply>) {
       desolate = engine
    }

    public init() {
        desolate = Supply.create()
    }
}
