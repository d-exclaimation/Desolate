//
//  NonStop.swift
//  Desolate
//
//  Created by d-exclaimation on 3:45 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// An Actor that conforms to an AbstractDesolate is always `.running`.
///
/// ```swift
/// actor Logger: AbstractBehavior, NonStop {
///     func onMessage(msg: String) async -> Signal {
///         print("[\(Date().ISO8601Format())]: \(msg)")
///         return same
///     }
/// }
/// ```
public protocol NonStop: Actor {}
