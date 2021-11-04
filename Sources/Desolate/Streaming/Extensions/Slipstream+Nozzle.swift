//
//  Slipstream+Nozzle.swift
//  Desolate
//
//  Created by d-exclaimation on 7:23 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Jet {
    /// Create a nozzle attached to this Jet
    ///
    /// - Returns: A new Nozzle
    public func nozzle() -> Nozzle<Element> {
        let (nozzle, flow) = Nozzle<Element>.desolate()
        defer {
            desolate.tell(with: .attach(id: nozzle.id, flow: flow))
        }
        return nozzle
    }

    /// Detach a nozzle from this Jet
    ///
    /// - Parameter id: UUID for the Nozzle
    public func erase(id: UUID) {
        desolate.tell(with: .detach(id: id))
    }

    /// Detach a nozzle from this Jet
    ///
    /// - Parameter nozzle: the Nozzle itself
    public func erase(nozzle: Nozzle<Element>) {
        desolate.tell(with: .detach(id: nozzle.id))
    }
}