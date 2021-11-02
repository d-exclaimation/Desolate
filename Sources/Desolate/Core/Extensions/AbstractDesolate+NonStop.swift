//
//  AbstractDesolate+NonStop.swift
//  Desolate
//
//  Created by d-exclaimation on 3:46 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension AbstractDesolate where Self: NonStop {
    /// The computed status Signal of a NonStop
    public var status: Signal {
        get { .running } set {}
    }

    /// Stub for returning return the same status
    public var same: Signal { .running }
}