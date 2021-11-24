//
//  AbstractBehavior+Receiver.swift
//  Desolate
//
//  Created by d-exclaimation on 1:33 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension AbstractDesolate {
    /// Get a Receiver from a AbstractDesolate
    public var ref: Receiver<MessageType> {
        DesolateReceiver(of: self)
    }

    /// Get a receiver from a AbstractDesolate with converter / transforms
    public func ref<ReceiverValueType>(_ transform: @escaping (ReceiverValueType) -> MessageType) -> Receiver<ReceiverValueType> {
        PipeableReceiver(of: self, transform: transform)
    }
}