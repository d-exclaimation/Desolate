//
//  AbstractDesolate+Timer.swift
//  Desolate
//
//  Created by d-exclaimation on 4:52 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension AbstractDesolate {
    /// Schedule a message to a recipient actor after a delay
    ///
    /// - Parameters:
    ///   - delay: TimeInterval delay
    ///   - target: Recipient desolated actor
    ///   - msg: Message being sent
    public func scheduleOnce<ActorType: AbstractDesolate>(
        delay: TimeInterval,
        target: Desolate<ActorType>,
        msg: ActorType.MessageType
    ) -> Hourglass {
        setTimeout(interval: delay) {
            target.tell(with: msg)
        }
    }
    /// Schedule a message to self after a delay
    ///
    /// - Parameters:
    ///   - delay: TimeInterval delay
    ///   - msg: Message being sent
    public func pipeSchedule(delay: TimeInterval, msg: MessageType) -> Hourglass {
        setTimeout(interval: delay) {
            self.oneself.tell(with: msg)
        }
    }
}