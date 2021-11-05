//
//  Source.swift
//  Desolate
//
//  Created by d-exclaimation on 9:13 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A Hot broadcast stream implementation using Desolated actors, that can easily create multiple ``Desolate/Nozzle``
public struct Jet<Element> {
    public typealias Flow = Desolate<Nozzle<Element>.Current>

    /// Actor to distribute to multiple Flows
    public actor Pipeline: AbstractDesolate, BaseActor {
        /// All actions for the Queue
        public enum Act {
            case next(Element), complete
            case attach(id: UUID, flow: Flow), detach(id: UUID)
        }

        public var status: Signal = .running

        /// Temporarily storage
        private var flows: [UUID: Flow] = [:]

        /// Interface for Desolate
        public func onMessage(msg: Act) async -> Signal {
            switch msg {
            case .next(let message):
                for nozzle in flows.values {
                    await nozzle.task(with: message)
                }
            case .complete:
                for queue in flows.values {
                    await queue.task(with: nil)
                }
                flows.removeAll()
                return .stopped
            case .attach(let id, let nozzle):
                flows[id] = nozzle
            case .detach(id: let id):
                flows.removeValue(forKey: id)
            }
            return .running
        }

        public init() {}
    }

    /// The desolated ``Desolate/Jet/Hub`` actor
    internal let desolate: Desolate<Pipeline>

    internal init(_ engine: Desolate<Pipeline>) {
       desolate = engine
    }

    public init() {
        desolate = Pipeline.create()
    }
}
