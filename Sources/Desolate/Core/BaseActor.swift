//
//  BaseDesolate.swift
//  Desolate
//
//  Created by d-exclaimation on 3:04 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Any Actor that can be instantiated with no parameters
///
/// ```
/// actor Logger: AbstractBehavior, BaseActor {
///     var status: Signal = .running
///
///     func onMessage(msg: String) async -> Signal {
///         print("[\(Date().ISO8601Format())]: \(msg)")
///         return .running
///     }
///
///     init() {}
/// }
///
/// let desolate: Desolate<Logger> = Logger.new()
///
/// desolate.tell(with: "Hello")
/// ```
public protocol BaseActor: Actor {
   init()
}
