//
//  Reservoir.swift
//  Desolate
//
//  Created by d-exclaimation on 2:59 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public struct Reservoir<Topic, Element>: Sendable where Topic: Hashable {
    public typealias Supply = Desolate<Source<Element>.Supply>

    public actor Spillway: AbstractDesolate, BaseActor {
        public enum Act {
            case acquire(topic: Topic, ref: Receiver<Supply>)
            case dispatch(topic: Topic, Element)
            case deallocate(topic: Topic)
        }

        public var status: Signal = .running

        /// Temporarily storage
        private var supplies: [Topic: Supply] = [:]

        public func onMessage(msg: Act) async -> Signal {
            switch msg {
            case .acquire(topic: let topic, ref: let ref):
                let supply = getOrElse(topic, or: Source<Element>.Supply.make)
                await ref.task(with: supply)

            case .dispatch(topic: let topic, let element):
                guard let supply = supplies[topic] else { break }
                await supply.task(with: .next(element))

            case .deallocate(topic: let topic):
                guard let supply = supplies[topic] else { break }
                await supply.task(with: .complete)
                supplies.removeValue(forKey: topic)
            }

            return .running
        }

        private func getOrElse(_ topic: Topic, or other: () -> Supply) -> Supply {
            if let supply = supplies[topic] {
                return supply
            }

            let supply = other()
            supplies[topic] = supply
            return supply
        }

        public init() {}
    }

    /// The desolated ``Desolate/Reservoir/Spillway`` actor
    internal let desolate: Desolate<Spillway>

    internal init(_ engine: Desolate<Spillway>) {
        desolate = engine
    }

    public init() {
        desolate = Spillway.make()
    }
}
