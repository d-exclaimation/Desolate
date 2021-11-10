//
//  TimeInterval+Nanoseconds.swift
//  Desolate
//
//  Created by d-exclaimation on 4:41 PM.
//  Copyright © 2021 d-exclaimation. All rights reserved.
//

import Foundation

extension TimeInterval {
    /// Time interval in millisecond
    public var millis: TimeInterval { self / 1000 }

    /// Time interval in microsecond
    public var micros: TimeInterval { millis / 1000 }

    /// Time interval to Nanoseconds
    public var nanoseconds: Nanoseconds { UInt64(self * 1000 * 1000 * 1000) }
}