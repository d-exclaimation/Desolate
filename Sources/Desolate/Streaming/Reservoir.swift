//
//  Reservoir.swift
//  Desolate
//
//  Created by d-exclaimation on 2:59 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

public struct Reservoir<Key, Element>: Sendable where Key: Hashable {
    public typealias Supply = Desolate<Source<Element>.Supply>

    public actor Spillway: AbstractDesolate, BaseActor {
        public enum Act {
            case acquire(key: Key, ref: Receiver<Supply>)
            case collect(key: Key, ref: Receiver<Nozzle<Element>>)
            case dispatch(key: Key, Element)
            case deallocate(key: Key)
        }

        public var status: Signal = .running

        /// Temporarily storage
        private var supplies: [Key: Supply] = [:]

        public func onMessage(msg: Act) async -> Signal {
            switch msg {
            case .acquire(key: let key, ref: let ref):
                let supply = await getOrElse(key, or: Source<Element>.Supply.make)
                await ref.task(with: supply)

            case .collect(key: let key, ref: let ref):
                let supply = await getOrElse(key, or: Source<Element>.Supply.make)

                let (nozzle, sink) = Nozzle<Element>.desolate()
                await supply.task(with: .attach(id: nozzle.id, sink: sink))
                nozzle.onTermination {
                    supply.tell(with: .detach(id: nozzle.id))
                }

                await ref.task(with: nozzle)

            case .dispatch(key: let key, let element):
                guard let supply = supplies[key] else { break }
                await supply.task(with: .next(element))

            case .deallocate(key: let key):
                guard let supply = supplies[key] else { break }
                await supply.task(with: .complete)
                supplies.removeValue(forKey: key)

            }
            return .running
        }

        private func getOrElse(_ key: Key, or other: () -> Supply) async -> Supply {
            if let supply = supplies[key] {
                return supply
            }

            let supply = other()
            supplies[key] = supply
            return supply
        }

        public init() {}
    }

    /// The desolated ``Desolate/Reservoir/Spillway`` actor
    internal let desolate: Desolate<Spillway>

    internal init(_ engine: Desolate<Spillway>) {
        desolate = engine
    }

    public init(key _: Key.Type = Key.self, element _: Element.Type = Element.self) {
        desolate = Spillway.make()
    }
}
