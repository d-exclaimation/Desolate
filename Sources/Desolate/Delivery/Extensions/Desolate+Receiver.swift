//
//  Desolate+Receiver.swift
//  Desolate
//
//  Created by d-exclaimation on 1:29 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension Desolate {
    // TODO: Add comment
    var ref: Receiver<ActorType.MessageType> {
        DesolateReceiver(of: innerActor)
    }
}