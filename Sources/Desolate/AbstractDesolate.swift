//
//  AbstractDesolate.swift
//  Desolate
//
//  Created by d-exclaimation on 9:16 AM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

/// Abstract Behavior for an Actor
public protocol AbstractDesolate: Actor {
    /// Associated type for the messages
    associatedtype MessageType

    /// Status of an Actor
    var status: Signal { get set }

    /// Receive messages with `at-most-once` basis and ordered guarantee and perform defined action
    ///
    /// - Parameter msg: Message received
    /// - Returns: A signal to let the ``Desolate/Desolate`` handle the Actor at the current state
    func onMessage(msg: MessageType) async -> Signal
}
