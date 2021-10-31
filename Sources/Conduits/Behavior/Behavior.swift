//
//  Behavior.swift
//  Conduits
//
//  Created by d-exclaimation on 7:58 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Singleton namespace for common behaviors
struct Behavior {

    /// Disable initializer
    private init() {}

    /// Empty Actor Behavior
    public static let empty: Empty = Empty.init()
}

public actor Empty: AbstractBehavior {
    public var status: BehaviorSignal = .stopped

    internal init() {}

    public func onMessage(msg: Void) async -> BehaviorSignal {
        .stopped
    }
}

