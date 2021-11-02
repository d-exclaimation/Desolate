//
//  AtomicProtocol.swift
//  Desolate
//
//  Created by d-exclaimation on 9:28 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// A protocol used for adding API to Desolate of an AsyncCapsule
internal protocol CapsuleInterface: Actor {
    associatedtype Value

    init(state: Value)
}
