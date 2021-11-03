//
//  Desolate+Receiver.swift
//  Desolate
//
//  Created by d-exclaimation on 1:29 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate {
    /// Get the receiver from this Desolate
    var ref: Receiver<ActorType.MessageType> {
        DesolateReceiver(of: innerActor)
    }

    /// Get a receiver from a AbstractDesolate with converter / mappers
    func ref<ReceiverValueType>(_ mapper: @escaping (ReceiverValueType) -> ActorType.MessageType) -> Receiver<ReceiverValueType> {
        PipeableReceiver(of: innerActor, mapper: mapper)
    }
}