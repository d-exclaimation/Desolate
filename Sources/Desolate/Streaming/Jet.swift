//
//  Source.swift
//  Desolate
//
//  Created by d-exclaimation on 9:13 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A Reactive stream implementation of hot stream using Actors
public struct Jet<Element> {
    public typealias Flow = Desolate<Nozzle<Element>.Current>

    /// Actor to distribute to multiple Flows
    public actor Pipeline: AbstractDesolate, BaseActor, NonStop {
        /// All actions for the Queue
        public enum Act {
            case next(Element), complete
            case attach(id: UUID, flow: Flow), detach(id: UUID)
        }

        /// Temporarily storage
        private var closed: Bool = false
        private var flows: [UUID: Flow] = [:]

        /// Interface for Desolate
        public func onMessage(msg: Act) async -> Signal {
            guard !closed else { return same }

            switch msg {
            case .next(let message):
                for nozzle in flows.values {
                    await nozzle.task(with: message)
                }
            case .complete:
                closed = true
                for queue in flows.values {
                    await queue.task(with: nil)
                }
                flows.removeAll()
            case .attach(let id, let nozzle):
                flows[id] = nozzle
            case .detach(id: let id):
                flows.removeValue(forKey: id)
            }
            return same
        }

        public init() {}
    }

    /// The desolated ``Desolate/Jet/Hub`` actor
    internal let desolate: Desolate<Pipeline> = Pipeline.create()

    public init() {}
}
