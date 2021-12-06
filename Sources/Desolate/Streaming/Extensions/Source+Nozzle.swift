//
//  Source+Nozzle.swift
//  Desolate
//
//  Created by d-exclaimation on 7:23 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Source {
    /// Create a nozzle attached to this Source
    ///
    /// - Returns: A new Nozzle
    public func nozzle() -> Nozzle<Element> {
        let (nozzle, sink) = Nozzle<Element>.desolate()
        defer {
            desolate.tell(with: .attach(id: nozzle.id, sink: sink))
            nozzle.onTermination {
                desolate.tell(with: .detach(id: nozzle.id))
            }
        }
        return nozzle
    }

    /// Detach a nozzle from this Source
    ///
    /// - Parameter id: UUID for the Nozzle
    public func erase(id: UUID) {
        desolate.tell(with: .detach(id: id))
    }

    /// Detach a nozzle from this Source
    ///
    /// - Parameter nozzle: the Nozzle itself
    public func erase(nozzle: Nozzle<Element>) {
        desolate.tell(with: .detach(id: nozzle.id))
    }
}